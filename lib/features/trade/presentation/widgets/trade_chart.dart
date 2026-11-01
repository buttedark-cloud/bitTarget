import 'dart:math' as math;

import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/core/utils/format.dart';
import 'package:bittarget/features/trade/data/trade_models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

// Поля вокруг области графика (для подписей осей); нужны и виджету, и рисовальщику
const double _kLeft = 48;
const double _kRight = 12;
const double _kTop = 10;
const double _kBottom = 24;
const int _kMaPeriod = 7;

class TradeChart extends StatefulWidget {
  final List<Candle> candles;
  final bool isUp;
  final bool showMa;
  final bool showDots;
  final String interval;
  final double height;

  const TradeChart({
    super.key,
    required this.candles,
    required this.isUp,
    required this.showMa,
    required this.showDots,
    required this.interval,
    this.height = 230,
  });

  @override
  State<TradeChart> createState() => _TradeChartState();
}

class _TradeChartState extends State<TradeChart> {
  // Выбранная точка хранится по времени, а не по номеру: график двигается, номера съезжают
  DateTime? _selectedTime;

  @override
  void didUpdateWidget(covariant TradeChart old) {
    super.didUpdateWidget(old);
    if (old.interval != widget.interval) _selectedTime = null;
  }

  // Какая точка ближе всего к месту касания
  void _select(double dx, double width, {bool toggle = false}) {
    final n = widget.candles.length;
    if (n < 2) return;

    final areaWidth = width - _kLeft - _kRight;
    final t = ((dx - _kLeft) / areaWidth).clamp(0.0, 1.0);
    final time = widget.candles[(t * (n - 1)).round()].time;

    setState(() => _selectedTime = (toggle && _selectedTime == time) ? null : time);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final selected = _selectedTime == null ? -1 : widget.candles.indexWhere((c) => c.time == _selectedTime);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => _select(d.localPosition.dx, width, toggle: true),
          onHorizontalDragStart: (d) => _select(d.localPosition.dx, width),
          onHorizontalDragUpdate: (d) => _select(d.localPosition.dx, width),
          child: SizedBox(
            height: widget.height,
            width: double.infinity,
            child: CustomPaint(
              painter: _TradeChartPainter(
                widget.candles,
                widget.isUp,
                widget.showMa,
                widget.showDots,
                widget.interval,
                selected >= 0 ? selected : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TradeChartPainter extends CustomPainter {
  final List<Candle> candles;
  final bool isUp;
  final bool showMa;
  final bool showDots;
  final String interval;
  final int? selectedIndex;

  _TradeChartPainter(this.candles, this.isUp, this.showMa, this.showDots, this.interval, this.selectedIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final n = candles.length;
    if (n < 2) return;

    final color = isUp ? AppColors.neonGreen : AppColors.neonRed;
    final area = Rect.fromLTRB(_kLeft, _kTop, size.width - _kRight, size.height - _kBottom);

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
      _label(canvas, yFormat.format(value), Offset(_kLeft - 8, y), size.width, alignRight: true);

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
        ..color = color.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
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
    if (showMa && n >= _kMaPeriod) {
      final ma = Path();
      for (int i = _kMaPeriod - 1; i < n; i++) {
        final avg = closes.sublist(i - _kMaPeriod + 1, i + 1).reduce((a, b) => a + b) / _kMaPeriod;
        final p = Offset(xOf(i), yOf(avg));
        if (i == _kMaPeriod - 1) {
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

    // Точки на линии (их можно скрыть в настройках) и выделенная последняя точка
    final dot = Paint()..color = color;
    if (showDots) {
      final step = math.max(1, ((n - 1) / 8).round());
      for (int i = 0; i < n; i += step) {
        canvas.drawCircle(Offset(xOf(i), yOf(closes[i])), 3, dot);
      }
    }
    final last = Offset(xOf(n - 1), yOf(closes.last));
    canvas.drawCircle(last, 7, Paint()..color = color.withValues(alpha: 0.25));
    canvas.drawCircle(last, 4, dot);

    // Выбранная точка: вертикальная линия и окошко с ценой и временем
    final sel = selectedIndex;
    if (sel != null && sel >= 0 && sel < n) {
      final p = Offset(xOf(sel), yOf(closes[sel]));

      canvas.drawLine(
        Offset(p.dx, area.top),
        Offset(p.dx, area.bottom),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..strokeWidth = 1,
      );
      canvas.drawCircle(p, 7, Paint()..color = Colors.white.withValues(alpha: 0.9));
      canvas.drawCircle(p, 4.5, Paint()..color = color);

      final timeFormat = interval == '1d' ? DateFormat('dd.MM.yyyy') : DateFormat('dd.MM HH:mm');
      final priceTp = TextPainter(
        text: TextSpan(
          text: formatUsd(closes[sel]),
          style: AppTypography.bodyLarge.copyWith(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final timeTp = TextPainter(
        text: TextSpan(text: timeFormat.format(candles[sel].time), style: AppTypography.caption.copyWith(fontSize: 10)),
        textDirection: TextDirection.ltr,
      )..layout();

      final w = math.max(priceTp.width, timeTp.width) + 20;
      final h = priceTp.height + timeTp.height + 12;
      final left = (p.dx - w / 2).clamp(area.left, math.max(area.left, area.right - w)).toDouble();

      // Окошко сверху; если точка у самого верха, переносим его ниже, чтобы не закрывать точку
      var top = area.top + 4;
      if (p.dy < top + h + 8) top = math.min(p.dy + 14, area.bottom - h);

      final box = RRect.fromRectAndRadius(Rect.fromLTWH(left, top, w, h), const Radius.circular(8));
      canvas.drawRRect(box, Paint()..color = const Color(0xFF161B18));
      canvas.drawRRect(
        box,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = color.withValues(alpha: 0.6),
      );
      priceTp.paint(canvas, Offset(left + (w - priceTp.width) / 2, top + 5));
      timeTp.paint(canvas, Offset(left + (w - timeTp.width) / 2, top + 5 + priceTp.height + 2));
    }
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
      old.candles != candles ||
      old.isUp != isUp ||
      old.showMa != showMa ||
      old.showDots != showDots ||
      old.interval != interval ||
      old.selectedIndex != selectedIndex;
}
