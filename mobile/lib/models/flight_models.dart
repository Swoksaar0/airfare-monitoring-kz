import 'dart:math' as math;

String dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

DateTime calendarDate(DateTime date) =>
    DateTime(date.year, date.month, date.day);
String displayDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

String money(double value) {
  final parts = value.toStringAsFixed(2).split('.');
  final digits =
      parts.first.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');
  return '$digits${parts.last == '00' ? '' : ',${parts.last}'} KZT';
}

int? parseThreshold(String value) {
  final normalized = value.trim().replaceAll(' ', '').replaceAll(',', '.');
  if (!RegExp(r'^\d{1,8}(\.\d{1,2})?$').hasMatch(normalized)) return null;
  final parts = normalized.split('.');
  final minor = int.parse(parts[0]) * 100 +
      (parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0')));
  return minor > 0 ? minor : null;
}

class FlightRoute {
  const FlightRoute({
    required this.id,
    required this.originIata,
    required this.originCity,
    required this.destinationIata,
    required this.destinationCity,
    this.isActive = true,
  });
  final int id;
  final String originIata, originCity, destinationIata, destinationCity;
  final bool isActive;
  String get key => '$originIata-$destinationIata';
  String get title => '$originCity → $destinationCity';
  String get codes => '$originIata → $destinationIata';
  factory FlightRoute.fromJson(Map<String, dynamic> json) => FlightRoute(
      id: json['id'] as int,
      originIata: json['origin_iata'] as String,
      originCity: json['origin_city'] as String,
      destinationIata: json['destination_iata'] as String,
      destinationCity: json['destination_city'] as String,
      isActive: json['is_active'] as bool? ?? true);
}

// The inspected backend serializes naive UTC instants. Normalize those to UTC;
// do not reinterpret its departure date as an observation timestamp.
DateTime parseInstant(String value) {
  final hasZone = RegExp(r'(Z|[+-]\d\d:\d\d)$').hasMatch(value);
  return DateTime.parse(hasZone ? value : '${value}Z').toUtc();
}

class PriceSnapshot {
  const PriceSnapshot({
    required this.id,
    required this.routeId,
    required this.departureDate,
    required this.priceKzt,
    required this.collectedAt,
    this.sourceFoundAt,
    this.airlineCode,
    this.flightNumber,
    this.isFresh,
    this.isCached,
    this.source,
    this.isDemo = false,
  });
  final int id, routeId;
  final String departureDate;
  final double priceKzt;
  final DateTime collectedAt;
  final DateTime? sourceFoundAt;
  final String? airlineCode, flightNumber, source;
  final bool? isFresh, isCached;
  final bool isDemo;

  bool get invalidSourceTime =>
      sourceFoundAt != null && sourceFoundAt!.isAfter(collectedAt);
  DateTime? get trustedSourceTime => invalidSourceTime ? null : sourceFoundAt;

  factory PriceSnapshot.fromJson(Map<String, dynamic> json) {
    final price = (json['price_kzt'] as num).toDouble();
    if (!price.isFinite || price <= 0) {
      throw const FormatException('Invalid price');
    }
    if (json['currency'] != null && json['currency'] != 'KZT') {
      throw const FormatException('Unsupported currency');
    }
    return PriceSnapshot(
      id: json['id'] as int,
      routeId: json['route_id'] as int,
      departureDate: json['departure_date'] as String,
      priceKzt: price,
      collectedAt: parseInstant(json['collected_at'] as String),
      sourceFoundAt: json['source_found_at'] == null
          ? null
          : parseInstant(json['source_found_at'] as String),
      airlineCode: json['airline_code'] as String?,
      flightNumber: json['flight_number'] as String?,
      source: json['source'] as String?,
      isFresh: json['is_fresh'] as bool?,
      isCached: json['is_cached'] as bool?,
      isDemo: json['is_demo'] as bool? ?? false,
    );
  }
}

class PriceSummary {
  PriceSummary(List<PriceSnapshot> observations)
      : history = List.unmodifiable([...observations]
          ..sort((a, b) => a.collectedAt.compareTo(b.collectedAt)));
  final List<PriceSnapshot> history;
  PriceSnapshot? get latest => history.isEmpty ? null : history.last;
  double? get priorMedian {
    if (history.length < 2) return null;
    final previous = history
        .take(history.length - 1)
        .map((p) => p.priceKzt)
        .toList()
      ..sort();
    final middle = previous.length ~/ 2;
    return previous.length.isOdd
        ? previous[middle]
        : (previous[middle - 1] + previous[middle]) / 2;
  }

  double? get minimum =>
      history.isEmpty ? null : history.map((p) => p.priceKzt).reduce(math.min);
  double? get changePercent => history.length < 2
      ? null
      : (history.last.priceKzt / history.first.priceKzt - 1) * 100;
  String get assessment {
    final median = priorMedian;
    if (median == null) return 'Недостаточно данных';
    if (latest!.priceKzt <= median * .92) return 'Ниже прошлой медианы';
    if (latest!.priceKzt >= median * 1.08) return 'Выше прошлой медианы';
    return 'Около прошлой медианы';
  }
}

class TrackingRule {
  const TrackingRule({
    required this.route,
    required this.departureDate,
    required this.thresholdMinor,
    required this.createdAt,
    this.isActive = true,
  });
  final FlightRoute route;
  final String departureDate;
  final int thresholdMinor;
  final DateTime createdAt;
  final bool isActive;
  String get key => '${route.key}|$departureDate';
  double get thresholdKzt => thresholdMinor / 100;
  bool expired(DateTime now) =>
      departureDate.compareTo(dateKey(calendarDate(now))) < 0;
  TrackingRule withActive(bool active) => TrackingRule(
      route: route,
      departureDate: departureDate,
      thresholdMinor: thresholdMinor,
      createdAt: createdAt,
      isActive: active);
  Map<String, dynamic> toJson() => {
        'route': {
          'id': route.id,
          'origin_iata': route.originIata,
          'origin_city': route.originCity,
          'destination_iata': route.destinationIata,
          'destination_city': route.destinationCity,
        },
        'departure_date': departureDate,
        'threshold_minor': thresholdMinor,
        'created_at': createdAt.toUtc().toIso8601String(),
        'is_active': isActive,
      };
  factory TrackingRule.fromJson(Map<String, dynamic> json) {
    final threshold = json['threshold_minor'] as int;
    final departure = json['departure_date'] as String;
    if (threshold <= 0 || dateKey(DateTime.parse(departure)) != departure) {
      throw const FormatException('Invalid saved rule');
    }
    return TrackingRule(
      route: FlightRoute.fromJson(json['route'] as Map<String, dynamic>),
      departureDate: departure,
      thresholdMinor: threshold,
      createdAt: parseInstant(json['created_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

