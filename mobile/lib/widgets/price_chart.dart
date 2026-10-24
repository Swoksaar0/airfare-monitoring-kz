import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/flight_models.dart';

class PriceChart extends StatelessWidget {
  const PriceChart(
      {super.key, required this.history, required this.selectedIndex});
  final List<PriceSnapshot> history;
  final int selectedIndex;
  @override
  Widget build(BuildContext context) => Semantics(
        label:
            'График цены по времени наблюдения. Точные значения доступны в списке под графиком.',
        child: ExcludeSemantics(
            child: SizedBox(
                height: 190,
                child: CustomPaint(
                    painter: _Painter(history, selectedIndex,
                        Theme.of(context).colorScheme.primary),
                    child: const SizedBox.expand()))),
      );
}

class _Painter extends CustomPainter {
  _Painter(this.history, this.selected, this.color);
  final List<PriceSnapshot> history;
  final int selected;
  final Color color;
  void label(Canvas c, String text, Offset p, {bool right = false}) {
    final painter = TextPainter(
        text: TextSpan(
            text: text,
            style: const TextStyle(color: Color(0xFF4A5363), fontSize: 11)),
        textDirection: TextDirection.ltr)
      ..layout();
    painter.paint(c, Offset(right ? p.dx - painter.width : p.dx, p.dy));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;
    const left = 66.0, top = 12.0, bottom = 30.0;
    final right = size.width - 12;
    final height = size.height - top - bottom;
    if (right <= left || height <= 0) return;
    final prices = history.map((p) => p.priceKzt).toList();
    final low = prices.reduce(math.min), high = prices.reduce(math.max);
    final padding = math.max((high - low) * .12, 500.0);
    final minY = low - padding, maxY = high + padding;
    final first = history.first.collectedAt.millisecondsSinceEpoch;
    final span = history.last.collectedAt.millisecondsSinceEpoch - first;
    final points = <Offset>[];
    for (var i = 0; i < history.length; i++) {
      final x = span == 0
          ? (left + right) / 2
          : left +
              (history[i].collectedAt.millisecondsSinceEpoch - first) /
                  span *
                  (right - left);
      final y = top + (maxY - prices[i]) / (maxY - minY) * height;
      points.add(Offset(x, y));
    }
    final grid = Paint()
      ..color = const Color(0xFFE0E5EE)
      ..strokeWidth = 1;
    for (var i = 0; i < 3; i++) {
      final y = top + height * i / 2;
      canvas.drawLine(Offset(left, y), Offset(right, y), grid);
      label(canvas, (maxY - (maxY - minY) * i / 2).round().toString(),
          Offset(0, y - 7));
    }
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke);
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(
          points[i], i == selected ? 6 : 4, Paint()..color = color);
      if (i == selected) {
        canvas.drawCircle(points[i], 3, Paint()..color = Colors.white);
      }
    }
    label(canvas, displayDate(history.first.collectedAt.toLocal()),
        Offset(left, size.height - 19));
    if (history.length > 1) {
      label(canvas, displayDate(history.last.collectedAt.toLocal()),
          Offset(right, size.height - 19),
          right: true);
    }
  }

  @override
  bool shouldRepaint(covariant _Painter old) =>
      old.history != history || old.selected != selected || old.color != color;
}

