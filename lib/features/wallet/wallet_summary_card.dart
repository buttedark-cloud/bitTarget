import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/nav/nav_cubit.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/core/utils/format.dart';
import 'package:bittarget/core/widgets/action_square_button.dart';
import 'package:bittarget/core/widgets/glass_card.dart';
import 'package:bittarget/features/wallet/presentation/widgets/wallet_action_sheet.dart';
import 'package:bittarget/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          // Wrap переносит плашку на вторую строку, если рядом нет места
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
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
          // Крупная сумма уменьшается, если не помещается по ширине
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(formatUsd(totalUsd), style: AppTypography.displayLarge.copyWith(fontSize: 32, color: Colors.white)),
          ),
          const SizedBox(height: 4),
          Text('≈ ${btcEquivalent.toStringAsFixed(6)} BTC', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
          const SizedBox(height: 16),
          // Каждая кнопка получает равную долю ширины
          Row(
            children: [
              Expanded(
                child: ActionSquareButton(
                  icon: Icons.arrow_downward,
                  label: l10n.deposit,
                  onTap: () => showWalletActionSheet(context, WalletAction.deposit),
                ),
              ),
              Expanded(
                child: ActionSquareButton(
                  icon: Icons.arrow_upward,
                  label: l10n.withdraw,
                  onTap: () => showWalletActionSheet(context, WalletAction.withdraw),
                ),
              ),
              Expanded(
                child: ActionSquareButton(icon: Icons.swap_horiz, label: l10n.trade, onTap: () => context.read<NavCubit>().goTo(1)),
              ),
              Expanded(
                child: ActionSquareButton(
                  icon: Icons.send_rounded,
                  label: l10n.transfer,
                  onTap: () => showWalletActionSheet(context, WalletAction.transfer),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
