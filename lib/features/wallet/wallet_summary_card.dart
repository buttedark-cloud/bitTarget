import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/core/utils/format.dart';
import 'package:bittarget/core/widgets/glass_card.dart';
import 'package:bittarget/core/widgets/press_effect.dart';
import 'package:bittarget/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class WalletSummaryCard extends StatelessWidget {
  final double totalUsd;
  final double btcEquivalent;

  const WalletSummaryCard({super.key, required this.totalUsd, required this.btcEquivalent});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GlassCard(
      glow: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.totalBalance, style: AppTypography.caption),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.35)),
                ),
                child: Text('+24,8% ${l10n.todayLabel}', style: AppTypography.badgeGreen),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(formatUsd(totalUsd), style: AppTypography.displayLarge.copyWith(fontSize: 32, color: Colors.white)),
          const SizedBox(height: 4),
          Text('≈ ${btcEquivalent.toStringAsFixed(6)} BTC', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),

          // Лёгкая полоска между балансом и кнопками
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ActionButton(icon: Icons.arrow_downward, label: l10n.deposit),
              _ActionButton(icon: Icons.arrow_upward, label: l10n.withdraw),
              _ActionButton(icon: Icons.swap_horiz, label: l10n.trade),
              _ActionButton(icon: Icons.send_rounded, label: l10n.transfer),
            ],
          ),
        ],
      ),
    );
  }
}

// Серая стеклянная кнопка, которая загорается зелёным, пока её держат нажатой
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;

  const _ActionButton({required this.icon, required this.label});

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const duration = Duration(milliseconds: 150);

    return PressEffect(
      scale: 0.9,
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
