import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flight_models.dart';

class ApiService {
  static const bool demoMode =
      bool.fromEnvironment('DEMO_MODE', defaultValue: true);
  static const String demoDepartureDate = '2026-11-06';
  final String baseUrl;

  ApiService(
      {this.baseUrl = const String.fromEnvironment('API_BASE_URL',
          defaultValue: 'http://127.0.0.1:8000')});

  Future<List<FlightRoute>> getRoutes() async {
    if (demoMode) return List.unmodifiable(_demoRoutes);
    final response = await http
        .get(Uri.parse('$baseUrl/api/v1/routes'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) {
      throw StateError(
          'Не удалось загрузить маршруты: HTTP ${response.statusCode}');
    }
    final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return data
        .map((item) => FlightRoute.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<PriceSnapshot>> getRouteHistory(int routeId) async {
    if (demoMode) return _demoHistory(routeId);
    final response = await http
        .get(Uri.parse(
            '$baseUrl/api/v1/routes/$routeId/history?only_fresh=true'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) {
      throw StateError(
          'Не удалось загрузить историю: HTTP ${response.statusCode}');
    }
    final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return data
        .map((item) => PriceSnapshot.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<RouteAnalytics> getRouteAnalytics(int routeId) async {
    if (demoMode) {
      final route = _demoRoutes.firstWhere((route) => route.id == routeId);
      return RouteAnalytics(
        routeId: routeId,
        originIata: route.originIata,
        destinationIata: route.destinationIata,
        departureDate: demoDepartureDate,
        currentMinPriceKzt: 23461,
        historicalMedianKzt: 25000,
        expectedPriceLinearKzt: null,
        priceAssessment: 'TYPICAL',
        totalObservations: 5,
      );
    }
    final response = await http
        .get(Uri.parse('$baseUrl/api/v1/routes/$routeId/analytics'))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode != 200) {
      throw StateError(
          'Не удалось загрузить аналитику: HTTP ${response.statusCode}');
    }
    return RouteAnalytics.fromJson(
        json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>);
  }

  Future<bool> createAlert(
      {required int routeId,
      required String departureDate,
      required double thresholdKzt}) async {
    if (!thresholdKzt.isFinite || thresholdKzt <= 0) return false;
    if (demoMode) {
      return true; // Session-local demo rule; no provider request or delivery.
    }
    const deviceToken = String.fromEnvironment('DEVICE_TOKEN');
    if (deviceToken.isEmpty) return false;
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/v1/alerts'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'device_token': deviceToken,
              'route_id': routeId,
              'departure_date': departureDate,
              'threshold_kzt': thresholdKzt
            }),
          )
          .timeout(const Duration(seconds: 5));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  static final List<FlightRoute> _demoRoutes = [
    _route(1, 'ALA', 'Алматы', 'NQZ', 'Астана'),
    _route(2, 'NQZ', 'Астана', 'ALA', 'Алматы'),
    _route(3, 'ALA', 'Алматы', 'CIT', 'Шымкент'),
    _route(4, 'ALA', 'Алматы', 'SCO', 'Актау'),
    _route(5, 'ALA', 'Алматы', 'GUW', 'Атырау'),
    _route(6, 'ALA', 'Алматы', 'AKX', 'Актобе'),
    _route(7, 'NQZ', 'Астана', 'CIT', 'Шымкент'),
    _route(8, 'NQZ', 'Астана', 'SCO', 'Актау'),
    _route(9, 'NQZ', 'Астана', 'GUW', 'Атырау'),
    _route(10, 'NQZ', 'Астана', 'AKX', 'Актобе'),
    _route(11, 'NQZ', 'Астана', 'UKK', 'Усть-Каменогорск'),
    _route(12, 'ALA', 'Алматы', 'KGF', 'Караганда'),
  ];

  static FlightRoute _route(int id, String origin, String originCity,
          String destination, String destinationCity) =>
      FlightRoute(
        id: id,
        originIata: origin,
        originCity: originCity,
        destinationIata: destination,
        destinationCity: destinationCity,
        isActive: true,
      );

  static List<PriceSnapshot> _demoHistory(int routeId) {
    final prices = [26500.0, 25200.0, 24800.0, 23900.0, 23461.0];
    final firstObservation = DateTime.utc(2026, 10, 19, 9, 15);
    final departure = DateTime.parse(demoDepartureDate);
    return List.generate(prices.length, (i) {
      final collectedAt = firstObservation.add(Duration(days: i));
      return PriceSnapshot(
        id: i + 1,
        routeId: routeId,
        departureDate: demoDepartureDate,
        priceKzt: prices[i],
        airlineCode: null,
        transfers: 0,
        collectedAt: collectedAt,
        isFresh: false,
        daysBeforeDeparture: departure
            .difference(DateTime.utc(
                collectedAt.year, collectedAt.month, collectedAt.day))
            .inDays,
      );
    });
  }
}
