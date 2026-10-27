import 'package:bittarget/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool glow;

  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.radius = 20, this.glow = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _GlassBorderPainter(radius: radius, glow: glow),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              // Стекло: почти прозрачная нейтральная заливка
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white.withValues(alpha: 0.06), Colors.white.withValues(alpha: 0.015)],
                    ),
                  ),
                ),
              ),
              // Слабое зелёное свечение только у правого нижнего края
              if (glow)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(1.1, 0.9),
                        radius: 0.9,
                        colors: [AppColors.neonGreen.withValues(alpha: 0.13), AppColors.neonGreen.withValues(alpha: 0)],
                      ),
                    ),
                  ),
                ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassBorderPainter extends CustomPainter {
  final double radius;
  final bool glow;

  _GlassBorderPainter({required this.radius, required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect.deflate(0.5), Radius.circular(radius));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: glow
            ? [Colors.white.withValues(alpha: 0.10), Colors.white.withValues(alpha: 0.05), AppColors.neonGreen.withValues(alpha: 0.35)]
            : [Colors.white.withValues(alpha: 0.09), Colors.white.withValues(alpha: 0.05)],
        stops: glow ? const [0.0, 0.55, 1.0] : null,
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GlassBorderPainter old) => old.radius != radius || old.glow != glow;
}
