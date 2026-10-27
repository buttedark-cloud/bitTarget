import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PressEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final ValueChanged<bool>? onPressedChanged;

  const PressEffect({super.key, required this.child, this.onTap, this.scale = 0.96, this.onPressedChanged});

  @override
  State<PressEffect> createState() => _PressEffectState();
}

class _PressEffectState extends State<PressEffect> {
  bool _pressed = false;
  int _gen = 0;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
    widget.onPressedChanged?.call(value);
  }

  void _press() {
    _gen++;
    _setPressed(true);
  }

  // Отпускаем с небольшой задержкой, чтобы короткий тап был заметен
  void _release() {
    final gen = ++_gen;
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted && gen == _gen) _setPressed(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _press(),
      onTapUp: (_) => _release(),
      onTapCancel: _release,
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: AnimatedOpacity(opacity: _pressed ? 0.8 : 1.0, duration: const Duration(milliseconds: 110), child: widget.child),
      ),
    );
  }
}
