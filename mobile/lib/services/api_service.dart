import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flight_models.dart';

enum DemoScenario { normal, empty, error, stale, single }

extension ScenarioLabel on DemoScenario {
  String get label => switch (this) {
        DemoScenario.normal => 'Пример истории',
        DemoScenario.empty => 'Нет данных',
        DemoScenario.error => 'Ошибка загрузки',
        DemoScenario.stale => 'Устаревшие данные',
        DemoScenario.single => 'Одно наблюдение',
      };
}

class ApiService {
  ApiService({
    this.baseUrl = const String.fromEnvironment('API_BASE_URL',
        defaultValue: 'http://127.0.0.1:8000'),
    this.demo = demoMode,
    http.Client? client,
    DateTime Function()? now,
    this.demoDelay = const Duration(milliseconds: 350),
  })  : _client = client ?? http.Client(),
        now = now ?? DateTime.now;
  static const bool demoMode =
      bool.fromEnvironment('DEMO_MODE', defaultValue: true);
  final String baseUrl;
  final bool demo;
  final http.Client _client;
  final DateTime Function() now;
  final Duration demoDelay;

  void dispose() => _client.close();
  Future<List<FlightRoute>> getRoutes() async {
    if (demo) return List.unmodifiable(_routes);
    final response = await _client
        .get(Uri.parse('$baseUrl/api/v1/routes'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) throw StateError('Route request failed');
    final list = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return list
        .map((r) => FlightRoute.fromJson(r as Map<String, dynamic>))
        .where((r) => r.isActive)
        .toList();
  }

  Future<List<PriceSnapshot>> getRouteHistory(
      FlightRoute route, DateTime departure,
      {DemoScenario scenario = DemoScenario.normal}) async {
    final target = dateKey(departure);
    if (!calendarDate(departure).isAfter(calendarDate(now()))) {
      throw ArgumentError('Choose a future departure date');
    }
    if (demo) {
      await Future<void>.delayed(demoDelay);
      if (scenario == DemoScenario.error) {
        throw StateError('Demonstration of a failed request');
      }
      if (scenario == DemoScenario.empty) return [];
      final count = scenario == DemoScenario.single ? 1 : 5;
      final last = now().toUtc().subtract(scenario == DemoScenario.stale
          ? const Duration(hours: 72)
          : const Duration(minutes: 30));
      final base = 16500 + route.id * 1450 + departure.weekday * 350;
      const multipliers = [1.12, 1.07, 1.04, 1.02, .97];
      return List.generate(
          count,
          (i) => PriceSnapshot(
                id: i + 1,
                routeId: route.id,
                departureDate: target,
                priceKzt: (base * multipliers[5 - count + i]).roundToDouble(),
                collectedAt: last.subtract(Duration(days: count - 1 - i)),
                source: 'Демонстрационный набор',
                isFresh: false,
                isDemo: true,
              ));
    }
    // The current backend ignores departure_date. Apply the same filter locally
    // until its server contract is fixed; never mix two departure histories.
    final uri = Uri.parse('$baseUrl/api/v1/routes/${route.id}/history').replace(
        queryParameters: {'only_fresh': 'false', 'departure_date': target});
    final response =
        await _client.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) throw StateError('History request failed');
    final list = jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    final result = list
        .map((item) => PriceSnapshot.fromJson(item as Map<String, dynamic>))
        .where(
            (item) => item.routeId == route.id && item.departureDate == target)
        .toList()
      ..sort((a, b) => a.collectedAt.compareTo(b.collectedAt));
    return result;
  }

  static const _routes = [
    FlightRoute(
        id: 1,
        originIata: 'ALA',
        originCity: 'Алматы',
        destinationIata: 'NQZ',
        destinationCity: 'Астана'),
    FlightRoute(
        id: 2,
        originIata: 'NQZ',
        originCity: 'Астана',
        destinationIata: 'ALA',
        destinationCity: 'Алматы'),
    FlightRoute(
        id: 3,
        originIata: 'ALA',
        originCity: 'Алматы',
        destinationIata: 'CIT',
        destinationCity: 'Шымкент'),
    FlightRoute(
        id: 4,
        originIata: 'ALA',
        originCity: 'Алматы',
        destinationIata: 'SCO',
        destinationCity: 'Актау'),
    FlightRoute(
        id: 5,
        originIata: 'ALA',
        originCity: 'Алматы',
        destinationIata: 'GUW',
        destinationCity: 'Атырау'),
    FlightRoute(
        id: 6,
        originIata: 'ALA',
        originCity: 'Алматы',
        destinationIata: 'AKX',
        destinationCity: 'Актобе'),
    FlightRoute(
        id: 7,
        originIata: 'NQZ',
        originCity: 'Астана',
        destinationIata: 'CIT',
        destinationCity: 'Шымкент'),
    FlightRoute(
        id: 8,
        originIata: 'NQZ',
        originCity: 'Астана',
        destinationIata: 'SCO',
        destinationCity: 'Актау'),
    FlightRoute(
        id: 9,
        originIata: 'NQZ',
        originCity: 'Астана',
        destinationIata: 'GUW',
        destinationCity: 'Атырау'),
    FlightRoute(
        id: 10,
        originIata: 'NQZ',
        originCity: 'Астана',
        destinationIata: 'AKX',
        destinationCity: 'Актобе'),
    FlightRoute(
        id: 11,
        originIata: 'NQZ',
        originCity: 'Астана',
        destinationIata: 'UKK',
        destinationCity: 'Усть-Каменогорск'),
    FlightRoute(
        id: 12,
        originIata: 'ALA',
        originCity: 'Алматы',
        destinationIata: 'KGF',
        destinationCity: 'Караганда'),
  ];
}

