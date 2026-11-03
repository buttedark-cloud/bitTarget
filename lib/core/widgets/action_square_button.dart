import 'dart:math' as math;

import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/core/widgets/press_effect.dart';
import 'package:flutter/material.dart';

class ActionSquareButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const ActionSquareButton({super.key, required this.icon, required this.label, this.onTap});

  @override
  State<ActionSquareButton> createState() => _ActionSquareButtonState();
}

class _ActionSquareButtonState extends State<ActionSquareButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 150);

    // Квадрат уменьшается, если в ячейке мало места
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth.isFinite ? constraints.maxWidth : 60.0;
        final size = math.min(52.0, math.max(34.0, available - 8));

        return PressEffect(
          scale: 0.9,
          onTap: widget.onTap,
          onPressedChanged: (value) => setState(() => _pressed = value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: duration,
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _pressed ? AppColors.neonGreen : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _pressed ? Colors.transparent : Colors.white.withValues(alpha: 0.10)),
                  boxShadow: _pressed
                      ? [BoxShadow(color: AppColors.neonGreen.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))]
                      : const [],
                ),
                child: TweenAnimationBuilder<Color?>(
                  tween: ColorTween(end: _pressed ? Colors.black : Colors.white),
                  duration: duration,
                  builder: (_, color, _) => Icon(widget.icon, color: color, size: size * 0.46),
                ),
              ),
              const SizedBox(height: 8),
              // Если подпись не помещается, она уменьшается
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.label,
                  maxLines: 1,
                  style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
