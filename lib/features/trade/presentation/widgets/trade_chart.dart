import 'dart:math' as math;

import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/features/trade/data/trade_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

class TradeChart extends StatelessWidget {
  final List<Candle> candles;
  final bool isUp;
  final bool showMa;
  final String interval;
  final double height;

  const TradeChart({super.key, required this.candles, required this.isUp, required this.showMa, required this.interval, this.height = 230});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _TradeChartPainter(candles, isUp, showMa, interval)),
    );
  }
}

class _TradeChartPainter extends CustomPainter {
  final List<Candle> candles;
  final bool isUp;
  final bool showMa;
  final String interval;

  _TradeChartPainter(this.candles, this.isUp, this.showMa, this.interval);

  static const double _left = 48;
  static const double _right = 12;
  static const double _top = 10;
  static const double _bottom = 24;
  static const int _maPeriod = 7;

  @override
  void paint(Canvas canvas, Size size) {
    final n = candles.length;
    if (n < 2) return;

    final color = isUp ? AppColors.neonGreen : AppColors.neonRed;
    final area = Rect.fromLTRB(_left, _top, size.width - _right, size.height - _bottom);

    final closes = candles.map((c) => c.close).toList();
    final minV = closes.reduce(math.min);
    final maxV = closes.reduce(math.max);
    final dataRange = (maxV - minV) == 0 ? maxV * 0.001 : maxV - minV;
    final lo = minV - dataRange * 0.08;
    final hi = maxV + dataRange * 0.08;
    final span = hi - lo;

    double xOf(int i) => area.left + area.width * i / (n - 1);
    double yOf(double v) => area.bottom - (v - lo) / span * area.height;

    // Сетка и подписи осей
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    final yFormat = NumberFormat.decimalPatternDigits(locale: 'en_US', decimalDigits: _decimals(span / 4));
    final xFormat = (interval == '15m' || interval == '1h') ? DateFormat('HH:mm') : DateFormat('dd.MM');

    for (int i = 0; i < 5; i++) {
      final value = lo + span * i / 4;
      final y = yOf(value);
      canvas.drawLine(Offset(area.left, y), Offset(area.right, y), gridPaint);
      _label(canvas, yFormat.format(value), Offset(_left - 8, y), size.width, alignRight: true);

      final idx = ((n - 1) * i / 4).round();
      final x = xOf(idx);
      canvas.drawLine(Offset(x, area.top), Offset(x, area.bottom), gridPaint);
      _label(canvas, xFormat.format(candles[idx].time), Offset(x, area.bottom + 12), size.width, center: true);
    }

    // Линия цены
    final line = Path()..moveTo(xOf(0), yOf(closes[0]));
    for (int i = 1; i < n; i++) {
      line.lineTo(xOf(i), yOf(closes[i]));
    }

    // Градиентная заливка под линией
    final fill = Path.from(line)
      ..lineTo(area.right, area.bottom)
      ..lineTo(area.left, area.bottom)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.30), color.withValues(alpha: 0)],
        ).createShader(area),
    );

    // Свечение и сама линия
    canvas.drawPath(
      line,
      Paint()
        ..color = color.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Скользящая средняя (MA)
    if (showMa && n >= _maPeriod) {
      final ma = Path();
      for (int i = _maPeriod - 1; i < n; i++) {
        final avg = closes.sublist(i - _maPeriod + 1, i + 1).reduce((a, b) => a + b) / _maPeriod;
        final p = Offset(xOf(i), yOf(avg));
        if (i == _maPeriod - 1) {
          ma.moveTo(p.dx, p.dy);
        } else {
          ma.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(
        ma,
        Paint()
          ..color = const Color(0xFFFFB800)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // Точки на линии и выделенная последняя точка
    final dot = Paint()..color = color;
    final step = math.max(1, ((n - 1) / 8).round());
    for (int i = 0; i < n; i += step) {
      canvas.drawCircle(Offset(xOf(i), yOf(closes[i])), 3, dot);
    }
    final last = Offset(xOf(n - 1), yOf(closes.last));
    canvas.drawCircle(last, 7, Paint()..color = color.withValues(alpha: 0.25));
    canvas.drawCircle(last, 4, dot);
  }

  // Сколько знаков после запятой нужно подписям, чтобы они не повторялись
  int _decimals(double step) {
    if (step >= 1) return 0;
    if (step >= 0.1) return 1;
    if (step >= 0.01) return 2;
    if (step >= 0.001) return 3;
    if (step >= 0.0001) return 4;
    return 6;
  }

  void _label(Canvas canvas, String text, Offset anchor, double maxWidth, {bool alignRight = false, bool center = false}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: AppTypography.caption.copyWith(fontSize: 10)),
      textDirection: TextDirection.ltr,
    )..layout();

    var dx = anchor.dx;
    if (alignRight) dx -= tp.width;
    if (center) dx -= tp.width / 2;
    dx = dx.clamp(0.0, maxWidth - tp.width).toDouble();

    tp.paint(canvas, Offset(dx, anchor.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _TradeChartPainter old) =>
      old.candles != candles || old.isUp != isUp || old.showMa != showMa || old.interval != interval;
}
