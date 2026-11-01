import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/core/utils/format.dart';
import 'package:bittarget/core/widgets/action_square_button.dart';
import 'package:bittarget/core/widgets/base_screen_layout.dart';
import 'package:bittarget/core/widgets/glass_card.dart';
import 'package:bittarget/features/home/data/crypto_asset_model.dart';
import 'package:bittarget/features/home/presentation/cubit/market_cubit.dart';
import 'package:bittarget/features/wallet/cubit/wallet_cubit.dart';
import 'package:bittarget/features/wallet/portfolio.dart';
import 'package:bittarget/features/wallet/presentation/widgets/allocation_card.dart';
import 'package:bittarget/features/wallet/presentation/widgets/transactions_section.dart';
import 'package:bittarget/features/wallet/presentation/widgets/wallet_action_sheet.dart';
import 'package:bittarget/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final wallet = context.watch<WalletCubit>().state;
    final market = context.watch<MarketCubit>().state;

    return BaseScreenLayout(
      child: market is MarketLoaded ? _content(context, l10n, wallet, market.assets) : _placeholder(context, l10n, market),
    );
  }

  // Пока нет цен рынка, стоимость монет посчитать нельзя
  Widget _placeholder(BuildContext context, AppLocalizations l10n, MarketState market) {
    if (market is MarketError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.marketLoadError, style: AppTypography.bodyLarge),
            const SizedBox(height: 12),
            TextButton(onPressed: () => context.read<MarketCubit>().loadMarket(), child: Text(l10n.retry)),
          ],
        ),
      );
    }
    return const Center(child: CircularProgressIndicator(color: AppColors.neonGreen));
  }

  Widget _content(BuildContext context, AppLocalizations l10n, WalletState wallet, List<CryptoAsset> assets) {
    final snap = buildPortfolio(wallet, assets);
    final positive = snap.pnl24h >= 0;
    final accent = positive ? AppColors.neonGreen : AppColors.neonRed;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(color: AppColors.neonGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.neonGreen, size: 18),
              ),
              const SizedBox(width: 10),
              Text(l10n.walletTitle, style: AppTypography.titleLarge),
              const Spacer(),
              const Icon(Icons.settings_rounded, color: AppColors.textSecondary, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          GlassCard(
            glow: true,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  l10n.estimatedNetWorth.toUpperCase(),
                  style: AppTypography.caption.copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(formatUsd(snap.netWorth), style: AppTypography.displayLarge.copyWith(fontSize: 36)),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(positive ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: accent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${positive ? '+' : '-'}${formatUsd(snap.pnl24h.abs())} (${l10n.profit24h})',
                      style: AppTypography.caption.copyWith(color: accent, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ActionSquareButton(
                      icon: Icons.arrow_downward,
                      label: l10n.deposit,
                      onTap: () => showWalletActionSheet(context, WalletAction.deposit),
                    ),
                    ActionSquareButton(
                      icon: Icons.arrow_upward,
                      label: l10n.withdraw,
                      onTap: () => showWalletActionSheet(context, WalletAction.withdraw),
                    ),
                    ActionSquareButton(
                      icon: Icons.swap_horiz,
                      label: l10n.convert,
                      onTap: () => showWalletActionSheet(context, WalletAction.convert),
                    ),
                    ActionSquareButton(
                      icon: Icons.send_rounded,
                      label: l10n.transfer,
                      onTap: () => showWalletActionSheet(context, WalletAction.transfer),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AllocationCard(snapshot: snap),
          const SizedBox(height: 24),
          TransactionsSection(transactions: wallet.transactions),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
