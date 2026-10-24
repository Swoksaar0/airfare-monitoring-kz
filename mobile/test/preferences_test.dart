import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kz_flights_mobile/models/flight_models.dart';
import 'package:kz_flights_mobile/services/preferences_service.dart';

const route = FlightRoute(
    id: 1,
    originIata: 'ALA',
    originCity: 'Алматы',
    destinationIata: 'NQZ',
    destinationCity: 'Астана');
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferences prefs;
  final clock = DateTime(2026, 10, 24);
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('favorites, date and rule activity survive state recreation', () async {
    final a = MonitorState(prefs, demo: true, now: () => clock);
    await a.toggleFavorite(route);
    await a.selectDate(DateTime(2026, 11, 7));
    await a.saveRule(route, DateTime(2026, 11, 7), 2500050);
    await a.setRuleActive(a.rules.single, false);
    final b = MonitorState(prefs, demo: true, now: () => clock);
    expect(b.isFavorite(route), isTrue);
    expect(b.departure, DateTime(2026, 11, 7));
    expect(b.rules.single.thresholdMinor, 2500050);
    expect(b.rules.single.isActive, isFalse);
    a.dispose();
    b.dispose();
  });

  test('two departure dates have independent rules and deletion is persisted',
      () async {
    final a = MonitorState(prefs, demo: true, now: () => clock);
    await a.saveRule(route, DateTime(2026, 11, 7), 2000000);
    await a.saveRule(route, DateTime(2026, 11, 8), 3000000);
    expect(a.rules.length, 2);
    await a.setRuleActive(a.ruleFor(route, DateTime(2026, 11, 7))!, false);
    expect(a.ruleFor(route, DateTime(2026, 11, 8))!.isActive, isTrue);
    await a.removeRule(a.ruleFor(route, DateTime(2026, 11, 7))!);
    final b = MonitorState(prefs, demo: true, now: () => clock);
    expect(b.rules.single.departureDate, '2026-11-08');
    a.dispose();
    b.dispose();
  });

  test('demo preferences never become API-mode tracking rules', () async {
    final a = MonitorState(prefs, demo: true, now: () => clock);
    await a.saveRule(route, DateTime(2026, 11, 7), 2000000);
    final b = MonitorState(prefs, demo: false, now: () => clock);
    expect(b.rules, isEmpty);
    a.dispose();
    b.dispose();
  });

  test('queued rapid favorites writes do not lose either update', () async {
    final a = MonitorState(prefs, demo: true, now: () => clock);
    const reverse = FlightRoute(
        id: 2,
        originIata: 'NQZ',
        originCity: 'Астана',
        destinationIata: 'ALA',
        destinationCity: 'Алматы');
    await Future.wait([a.toggleFavorite(route), a.toggleFavorite(reverse)]);
    final b = MonitorState(prefs, demo: true, now: () => clock);
    expect(b.favorites, {'ALA-NQZ', 'NQZ-ALA'});
    a.dispose();
    b.dispose();
  });

  test('corrupt saved state is reported and not silently overwritten',
      () async {
    await prefs.setString('airfare_monitor_v2_demo', 'broken');
    final a = MonitorState(prefs, demo: true, now: () => clock);
    expect(a.storageWarning, isNotNull);
    expect(prefs.getString(a.storageKey), 'broken');
    a.dispose();
  });
}

