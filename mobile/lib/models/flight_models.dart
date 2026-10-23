class FlightRoute {
  final int id;
  final String originIata;
  final String originCity;
  final String destinationIata;
  final String destinationCity;
  final bool isActive;

  FlightRoute({
    required this.id,
    required this.originIata,
    required this.originCity,
    required this.destinationIata,
    required this.destinationCity,
    required this.isActive,
  });

  factory FlightRoute.fromJson(Map<String, dynamic> json) {
    return FlightRoute(
      id: json['id'] as int,
      originIata: json['origin_iata'] as String,
      originCity: json['origin_city'] as String,
      destinationIata: json['destination_iata'] as String,
      destinationCity: json['destination_city'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  String get title =>
      '$originCity ($originIata) → $destinationCity ($destinationIata)';
}

class PriceSnapshot {
  final int id;
  final int routeId;
  final String departureDate;
  final double priceKzt;
  final String? airlineCode;
  final int transfers;
  final DateTime collectedAt;
  final bool isFresh;
  final int daysBeforeDeparture;

  PriceSnapshot({
    required this.id,
    required this.routeId,
    required this.departureDate,
    required this.priceKzt,
    this.airlineCode,
    required this.transfers,
    required this.collectedAt,
    required this.isFresh,
    required this.daysBeforeDeparture,
  });

  factory PriceSnapshot.fromJson(Map<String, dynamic> json) {
    return PriceSnapshot(
      id: json['id'] as int,
      routeId: json['route_id'] as int,
      departureDate: json['departure_date'] as String,
      priceKzt: (json['price_kzt'] as num).toDouble(),
      airlineCode: json['airline_code'] as String?,
      transfers: json['transfers'] as int? ?? 0,
      collectedAt: DateTime.parse(json['collected_at'] as String),
      isFresh: json['is_fresh'] as bool? ?? true,
      daysBeforeDeparture: json['days_before_departure'] as int? ?? 7,
    );
  }
}

class RouteAnalytics {
  final int routeId;
  final String originIata;
  final String destinationIata;
  final String departureDate;
  final double? currentMinPriceKzt;
  final double? historicalMedianKzt;
  final double? expectedPriceLinearKzt;
  final String priceAssessment;
  final int totalObservations;

  RouteAnalytics({
    required this.routeId,
    required this.originIata,
    required this.destinationIata,
    required this.departureDate,
    this.currentMinPriceKzt,
    this.historicalMedianKzt,
    this.expectedPriceLinearKzt,
    required this.priceAssessment,
    required this.totalObservations,
  });

  factory RouteAnalytics.fromJson(Map<String, dynamic> json) {
    return RouteAnalytics(
      routeId: json['route_id'] as int,
      originIata: json['origin_iata'] as String,
      destinationIata: json['destination_iata'] as String,
      departureDate: json['departure_date'] as String,
      currentMinPriceKzt: (json['current_min_price_kzt'] as num?)?.toDouble(),
      historicalMedianKzt: (json['historical_median_kzt'] as num?)?.toDouble(),
      expectedPriceLinearKzt:
          (json['expected_price_linear_kzt'] as num?)?.toDouble(),
      priceAssessment:
          json['price_assessment'] as String? ?? 'INSUFFICIENT_DATA',
      totalObservations: json['total_observations'] as int? ?? 0,
    );
  }
}
