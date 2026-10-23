import 'package:flutter/material.dart';
import '../models/flight_models.dart';
import '../services/api_service.dart';
import '../services/alert_service.dart';

class RouteDetailScreen extends StatefulWidget {
  final FlightRoute route;
  final ApiService apiService;
  final AlertNotificationService alertService;

  const RouteDetailScreen({
    super.key,
    required this.route,
    required this.apiService,
    required this.alertService,
  });

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  List<PriceSnapshot> _history = [];
  RouteAnalytics? _analytics;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  final TextEditingController _thresholdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final existingThreshold = widget.alertService.getThreshold(widget.route.id);
    if (existingThreshold != null) {
      _thresholdController.text = existingThreshold.toStringAsFixed(0);
    }
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final history = await widget.apiService.getRouteHistory(widget.route.id);
      final analytics =
          await widget.apiService.getRouteAnalytics(widget.route.id);
      if (!mounted) return;
      final matching = history
          .where((item) => item.departureDate == analytics.departureDate)
          .toList()
        ..sort((a, b) => a.collectedAt.compareTo(b.collectedAt));
      setState(() {
        _history = matching;
        _analytics = analytics;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Не удалось загрузить данные. Попробуйте ещё раз.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _saveThreshold() async {
    final value =
        double.tryParse(_thresholdController.text.trim().replaceAll(',', '.'));
    if (value == null || !value.isFinite || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Введите положительную конечную сумму.')));
      return;
    }
    if (_analytics == null) return;
    setState(() => _isSaving = true);
    final success = await widget.apiService.createAlert(
        routeId: widget.route.id,
        departureDate: _analytics!.departureDate,
        thresholdKzt: value);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (success) widget.alertService.setThreshold(widget.route.id, value);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      !success
          ? 'Не удалось сохранить правило на сервере. Проверьте подключение и настройку устройства.'
          : ApiService.demoMode
              ? 'Демопорог сохранён в памяти сеанса. Уведомления не отправляются.'
              : 'Правило сохранено на сервере. Push-доставка пока не подключена.',
    )));
  }

  Color _assessmentColor(String assessment) {
    switch (assessment) {
      case 'LOW':
        return Colors.green;
      case 'HIGH':
        return Colors.redAccent;
      default:
        return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.route.title)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_error!, textAlign: TextAlign.center),
                  TextButton(
                      onPressed: _loadDetails, child: const Text('Повторить'))
                ]))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_analytics != null) _buildAnalyticsCard(_analytics!),
                      const SizedBox(height: 16),
                      _buildChartCard(),
                      const SizedBox(height: 16),
                      _buildAlertThresholdCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildAnalyticsCard(RouteAnalytics a) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                const Text(
                  'Аналитическая оценка цены',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(
                    const {
                          'LOW': 'Ниже обычной',
                          'HIGH': 'Выше обычной',
                          'TYPICAL': 'Обычная',
                          'INSUFFICIENT_DATA': 'Недостаточно данных'
                        }[a.priceAssessment] ??
                        'Нет оценки',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _assessmentColor(a.priceAssessment),
                ),
              ],
            ),
            const Divider(),
            Text('Дата вылета: ${a.departureDate}'),
            const SizedBox(height: 6),
            Text(
                'Текущая мин. цена: ${a.currentMinPriceKzt?.toStringAsFixed(0) ?? "-"} KZT'),
            Text(
                'Историческая медиана: ${a.historicalMedianKzt?.toStringAsFixed(0) ?? "-"} KZT'),
            Text(
                'Оценка линейной модели: ${a.expectedPriceLinearKzt?.toStringAsFixed(0) ?? "-"} KZT'),
            Text(
                '${ApiService.demoMode ? 'Демонаблюдений' : 'Наблюдений'}: ${a.totalObservations}'),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'График динамики минимальной цены (KZT)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: _history.isEmpty
                  ? const Center(child: Text('Недостаточно данных для графика'))
                  : CustomPaint(
                      painter: _PriceLineChartPainter(_history),
                      child: Container(),
                    ),
            ),
            if (_history.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                  'Точки идут по порядку наблюдений. Дата вылета остаётся одной и той же.',
                  style: TextStyle(fontSize: 12)),
              for (final item in _history)
                Text(
                    '${item.collectedAt.toUtc().toIso8601String().substring(0, 10)}: ${item.priceKzt.toStringAsFixed(0)} KZT',
                    style: const TextStyle(fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAlertThresholdCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Уведомление о снижении цены',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _thresholdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Пороговая цена (KZT)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.notifications_active),
              label: Text(_isSaving
                  ? 'Сохраняем…'
                  : ApiService.demoMode
                      ? 'Сохранить демопорог'
                      : 'Сохранить порог'),
              onPressed:
                  _isSaving || _analytics == null ? null : _saveThreshold,
            ),
            const SizedBox(height: 10),
            const Text(
                'Избранное и локальные пороги действуют в рамках сеанса. Реальные push-уведомления пока не реализованы.',
                style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _PriceLineChartPainter extends CustomPainter {
  final List<PriceSnapshot> snapshots;
  _PriceLineChartPainter(this.snapshots);

  @override
  void paint(Canvas canvas, Size size) {
    if (snapshots.isEmpty) return;
    final paintLine = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final prices = snapshots.map((s) => s.priceKzt).toList();
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    final range = (maxPrice - minPrice) == 0 ? 1.0 : (maxPrice - minPrice);

    final path = Path();
    for (int i = 0; i < prices.length; i++) {
      final x = prices.length == 1
          ? size.width / 2
          : (i / (prices.length - 1)) * size.width;
      final y = size.height -
          ((prices[i] - minPrice) / range) * (size.height - 20) -
          10;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.blueAccent);
    }
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
