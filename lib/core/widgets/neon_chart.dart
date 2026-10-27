import 'package:bittarget/core/constants/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NeonChart extends StatelessWidget {
  final List<double> points;
  final bool isPositive;
  final double height;
  final double strokeWidth;
  final bool showFill;

  const NeonChart({
    super.key,
    required this.points,
    required this.isPositive,
    this.height = 70,
    this.strokeWidth = 2.5,
    this.showFill = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _NeonChartPainter(points, isPositive, strokeWidth, showFill)),
    );
  }
}

class _NeonChartPainter extends CustomPainter {
  final List<double> points;
  final bool isPositive;
  final double strokeWidth;
  final bool showFill;

  _NeonChartPainter(this.points, this.isPositive, this.strokeWidth, this.showFill);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final color = isPositive ? AppColors.neonGreen : AppColors.neonRed;
    final minVal = points.reduce((a, b) => a < b ? a : b);
    final maxVal = points.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1.0 : maxVal - minVal;

    const pad = 4.0;
    final dx = size.width / (points.length - 1);
    double yOf(double v) => size.height - pad - ((v - minVal) / range) * (size.height - pad * 2);

    final line = Path()..moveTo(0, yOf(points.first));
    for (int i = 1; i < points.length; i++) {
      line.lineTo(i * dx, yOf(points[i]));
    }

    if (showFill) {
      final fill = Path.from(line)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0)],
          ).createShader(Offset.zero & size),
      );
      canvas.drawPath(
        line,
        Paint()
          ..color = color.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth * 2.5
          ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _NeonChartPainter old) =>
      old.isPositive != isPositive || old.strokeWidth != strokeWidth || old.showFill != showFill || !listEquals(old.points, points);
}
