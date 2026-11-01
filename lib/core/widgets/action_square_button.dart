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

    return PressEffect(
      scale: 0.9,
      onTap: widget.onTap,
      onPressedChanged: (value) => setState(() => _pressed = value),
      child: Column(
        children: [
          AnimatedContainer(
            duration: duration,
            width: 52,
            height: 52,
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
              builder: (_, color, _) => Icon(widget.icon, color: color, size: 24),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.label,
            style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
