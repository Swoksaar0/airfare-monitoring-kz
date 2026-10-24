import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kz_flights_mobile/main.dart';
import 'package:kz_flights_mobile/services/api_service.dart';
import 'package:kz_flights_mobile/services/preferences_service.dart';

final clock = DateTime(2026, 10, 24, 15);
Future<(ApiService, MonitorState)> setup() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final api =
      ApiService(now: () => clock, demoDelay: const Duration(milliseconds: 10));
  return (api, MonitorState(prefs, demo: true, now: () => clock));
}

void main() {
  testWidgets('select date, validate threshold, persist and deactivate rule',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final (api, state) = await setup();
    await tester
        .pumpWidget(KzFlightsMonitorApp(apiService: api, initialState: state));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Через 14 дн.'));
    await tester.pumpAndSettle();
    expect(state.departure, DateTime(2026, 11, 7));
    await tester.tap(find.text('Алматы → Астана'));
    await tester.pumpAndSettle();
    expect(find.text('Вылет: 07.11.2026'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('threshold-input')));
    await tester.enterText(find.byKey(const Key('threshold-input')), '0');
    await tester.ensureVisible(find.byKey(const Key('save-rule')));
    await tester.tap(find.byKey(const Key('save-rule')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Введите положительную сумму'), findsOneWidget);
    await tester.enterText(
        find.byKey(const Key('threshold-input')), '25000,50');
    await tester.ensureVisible(find.byKey(const Key('save-rule')));
    await tester.tap(find.byKey(const Key('save-rule')));
    await tester.pumpAndSettle();
    expect(state.rules.single.thresholdMinor, 2500050);
    expect(state.rules.single.departureDate, '2026-11-07');
    expect(
        find.text('Сохранено на устройстве. Push-уведомления не отправляются.'),
        findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Отслеживание'));
    await tester.pumpAndSettle();
    expect(find.text('Правило активно'), findsOneWidget);
    await tester.tap(find.text('Правило активно'));
    await tester.pumpAndSettle();
    expect(state.rules.single.isActive, isFalse);
    expect(find.text('Правило отключено'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'no-data, failure, stale and single-observation states stay distinct',
      (tester) async {
    final (api, state) = await setup();
    await tester
        .pumpWidget(KzFlightsMonitorApp(apiService: api, initialState: state));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Алматы → Астана'));
    await tester.pumpAndSettle();

    Future<void> scenario(String label) async {
      await tester.ensureVisible(find.byKey(const Key('demo-scenario')));
      await tester.tap(find.byKey(const Key('demo-scenario')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
    }

    await scenario('Нет данных');
    expect(find.text('Для этой даты пока нет наблюдений'), findsOneWidget);
    expect(find.text('Динамика цены'), findsNothing);
    await scenario('Ошибка загрузки');
    expect(find.text('История недоступна'), findsOneWidget);
    expect(find.text('Для этой даты пока нет наблюдений'), findsNothing);
    expect(find.text('Повторить'), findsOneWidget);
    await scenario('Устаревшие данные');
    expect(find.textContaining('Данные устарели:'), findsOneWidget);
    await scenario('Одно наблюдение');
    expect(find.text('Недостаточно данных'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('date input rejects past date and reloads the accepted date',
      (tester) async {
    final (api, state) = await setup();
    await tester
        .pumpWidget(KzFlightsMonitorApp(apiService: api, initialState: state));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('departure-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    final field = find.descendant(
        of: find.byType(DatePickerDialog), matching: find.byType(TextField));
    await tester.enterText(field, '23.10.2026');
    await tester.tap(find.text('Выбрать'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    expect(state.departure, DateTime(2026, 10, 31));
    await tester.enterText(field, '08.11.2026');
    await tester.tap(find.text('Выбрать'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsNothing);
    expect(state.departure, DateTime(2026, 11, 8));
    expect(tester.takeException(), isNull);
  });

  testWidgets('search and favorites work with large text on a narrow screen',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final (api, state) = await setup();
    await tester.pumpWidget(MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
        child: KzFlightsMonitorApp(apiService: api, initialState: state)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('route-search')), 'NQZ');
    await tester.pumpAndSettle();
    expect(find.text('Алматы → Шымкент'), findsNothing);
    expect(
        MediaQuery.textScalerOf(tester.element(find.text('Алматы → Астана')))
            .scale(10),
        16);
    await tester.ensureVisible(find.byTooltip('В избранное: ALA → NQZ'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('В избранное: ALA → NQZ'));
    await tester.pumpAndSettle();
    expect(state.favorites, contains('ALA-NQZ'));
    await tester.tap(find.text('Избранное'));
    await tester.pumpAndSettle();
    expect(find.text('Алматы → Астана'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

