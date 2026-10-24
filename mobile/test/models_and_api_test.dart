import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kz_flights_mobile/models/flight_models.dart';
import 'package:kz_flights_mobile/services/api_service.dart';

PriceSnapshot observation(int id, double price) => PriceSnapshot(
    id: id,
    routeId: 1,
    departureDate: '2026-11-07',
    priceKzt: price,
    collectedAt: DateTime.utc(2026, 10, 20 + id));

void main() {
  test(
      'historical median excludes current observation and sorts by collection time',
      () {
    final result = PriceSummary(
        [observation(3, 100), observation(1, 10), observation(2, 20)]);
    expect(result.latest!.priceKzt, 100);
    expect(result.priorMedian, 15);
    expect(result.minimum, 10);
    expect(result.assessment, 'Выше прошлой медианы');
    expect(PriceSummary([observation(1, 10)]).priorMedian, isNull);
    expect(PriceSummary([]).latest, isNull);
  });

  test(
      'thresholds retain exact kopecks and reject invalid, zero and non-finite input',
      () {
    expect(parseThreshold('25 000,50'), 2500050);
    expect(parseThreshold('0.01'), 1);
    for (final text in [
      '0',
      '-1',
      'NaN',
      'Infinity',
      '1.234',
      'abc',
      '100000000'
    ]) {
      expect(parseThreshold(text), isNull, reason: text);
    }
    expect(money(25000.5), '25 000,50 KZT');
  });

  test(
      'unknown source metadata stays unknown and future source time is flagged',
      () {
    final p = PriceSnapshot.fromJson({
      'id': 1,
      'route_id': 1,
      'departure_date': '2026-11-07',
      'price_kzt': 20000,
      'collected_at': '2026-10-24T10:00:00',
      'source_found_at': '2026-11-07T10:00:00+00:00',
    });
    expect(p.collectedAt, DateTime.utc(2026, 10, 24, 10));
    expect(p.invalidSourceTime, isTrue);
    expect(p.trustedSourceTime, isNull);
    expect(p.airlineCode, isNull);
    expect(p.isCached, isNull);
    expect(p.isFresh, isNull);
  });

  test('invalid and non-KZT prices are rejected', () {
    final raw = {
      'id': 1,
      'route_id': 1,
      'departure_date': '2026-11-07',
      'price_kzt': -2,
      'collected_at': '2026-10-24T10:00:00Z'
    };
    expect(() => PriceSnapshot.fromJson(raw), throwsFormatException);
    raw['price_kzt'] = 100;
    raw['currency'] = 'USD';
    expect(() => PriceSnapshot.fromJson(raw), throwsFormatException);
  });

  test('demo never calls HTTP and history matches each selected direction/date',
      () async {
    var calls = 0;
    final api = ApiService(
        now: () => DateTime(2026, 10, 24),
        demoDelay: Duration.zero,
        client: MockClient((_) async {
          calls++;
          return http.Response('', 500);
        }));
    final routes = await api.getRoutes();
    expect(routes.length, 12);
    final a = await api.getRouteHistory(routes.first, DateTime(2026, 11, 7));
    final b = await api.getRouteHistory(routes[1], DateTime(2026, 11, 8));
    expect(
        a.every((p) =>
            p.routeId == 1 && p.departureDate == '2026-11-07' && p.isDemo),
        isTrue);
    expect(b.every((p) => p.routeId == 2 && p.departureDate == '2026-11-08'),
        isTrue);
    expect(a.last.priceKzt, isNot(b.last.priceKzt));
    expect(calls, 0);
    api.dispose();
  });

  test(
      'API passes selected date, filters mixed histories and preserves ordering',
      () async {
    final route = (await ApiService().getRoutes()).first;
    final api = ApiService(
        demo: false,
        now: () => DateTime(2026, 10, 24),
        client: MockClient((request) async {
          expect(request.url.queryParameters['departure_date'], '2026-11-07');
          expect(request.url.queryParameters['only_fresh'], 'false');
          Map<String, Object> item(int id, String date, int routeId) => {
                'id': id,
                'route_id': routeId,
                'departure_date': date,
                'price_kzt': 22000,
                'collected_at': '2026-10-${(20 + id).toString()}T09:00:00Z'
              };
          return http.Response(
              jsonEncode([
                item(2, '2026-11-07', 1),
                item(3, '2026-11-08', 1),
                item(4, '2026-11-07', 2),
                item(1, '2026-11-07', 1)
              ]),
              200);
        }));
    final data = await api.getRouteHistory(route, DateTime(2026, 11, 7));
    expect(data.map((p) => p.id), [1, 2]);
    api.dispose();
  });

  test('HTTP failure remains an error instead of generating a price', () async {
    final route = (await ApiService().getRoutes()).first;
    final api = ApiService(
        demo: false,
        now: () => DateTime(2026, 10, 24),
        client: MockClient((_) async => http.Response('failed', 503)));
    await expectLater(
        api.getRouteHistory(route, DateTime(2026, 11, 7)), throwsStateError);
    api.dispose();
  });

  test('past departure dates are rejected before a network request', () async {
    final route = (await ApiService().getRoutes()).first;
    var calls = 0;
    final api = ApiService(
        demo: false,
        now: () => DateTime(2026, 10, 24),
        client: MockClient((_) async {
          calls++;
          return http.Response('[]', 200);
        }));
    await expectLater(api.getRouteHistory(route, DateTime(2026, 10, 23)),
        throwsArgumentError);
    expect(calls, 0);
    api.dispose();
  });
}

