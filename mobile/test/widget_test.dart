import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kz_flights_mobile/main.dart';
import 'package:kz_flights_mobile/services/api_service.dart';

void main() {
  test('demo route metadata matches the selected direction', () async {
    final api = ApiService();
    final routes = await api.getRoutes();
    expect(routes.length, 12);
    final reverse = await api.getRouteAnalytics(2);
    expect(reverse.originIata, 'NQZ');
    expect(reverse.destinationIata, 'ALA');
    final history = await api.getRouteHistory(2);
    expect(
        history.every((item) =>
            item.routeId == 2 && item.departureDate == reverse.departureDate),
        isTrue);
    expect(history.every((item) => !item.isFresh), isTrue);
    expect(reverse.expectedPriceLinearKzt, isNull);
  });

  testWidgets('route opens and demo threshold does not claim push delivery',
      (tester) async {
    await tester.pumpWidget(const KzFlightsMonitorApp());
    await tester.pumpAndSettle();
    expect(find.textContaining('ДЕМО: искусственные цены'), findsOneWidget);
    expect(find.text('Все маршруты (12)'), findsOneWidget);
    await tester.tap(find.text('Алматы (ALA) → Астана (NQZ)'));
    await tester.pumpAndSettle();
    expect(find.text('Дата вылета: 2026-11-06'), findsOneWidget);
    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), '0');
    await tester.ensureVisible(find.text('Сохранить демопорог'));
    await tester.tap(find.text('Сохранить демопорог'));
    await tester.pumpAndSettle();
    expect(find.text('Введите положительную конечную сумму.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '30000');
    await tester.tap(find.text('Сохранить демопорог'));
    await tester.pumpAndSettle();
    expect(
        find.text(
            'Демопорог сохранён в памяти сеанса. Уведомления не отправляются.'),
        findsOneWidget);
    expect(find.textContaining('отправлено уведомление'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
