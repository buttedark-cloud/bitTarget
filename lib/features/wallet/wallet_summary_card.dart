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
              _buildActionButton(Icons.arrow_downward, l10n.deposit, highlighted: true),
              _buildActionButton(Icons.arrow_upward, l10n.withdraw),
              _buildActionButton(Icons.swap_horiz, l10n.trade),
              _buildActionButton(Icons.send_rounded, l10n.transfer),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, {bool highlighted = false}) {
    return PressEffect(
      scale: 0.9,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: highlighted ? AppColors.neonGreen : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: highlighted ? null : Border.all(color: Colors.white.withValues(alpha: 0.10)),
              boxShadow: highlighted
                  ? [BoxShadow(color: AppColors.neonGreen.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))]
                  : null,
            ),
            child: Icon(icon, color: highlighted ? Colors.black : Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
