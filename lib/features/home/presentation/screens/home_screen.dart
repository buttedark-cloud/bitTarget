import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/core/widgets/base_screen_layout.dart';
import 'package:bittarget/features/home/presentation/cubit/market_cubit.dart';
import 'package:bittarget/features/home/presentation/widgets/market_hero_card.dart';
import 'package:bittarget/features/home/presentation/widgets/market_overview_section.dart';
import 'package:bittarget/features/wallet/cubit/wallet_cubit.dart';
import 'package:bittarget/features/wallet/wallet_summary_card.dart';
import 'package:bittarget/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onLanguageToggle;
  final VoidCallback onProfileTap;

  const HomeScreen({super.key, required this.onLanguageToggle, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final langLabel = Localizations.localeOf(context).languageCode.toUpperCase();

    return BaseScreenLayout(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Шапка профиля и языка
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: onProfileTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.neonGreen, width: 1.5),
                                  color: AppColors.cardBackground,
                                ),
                                child: const Icon(Icons.person, color: Colors.white70, size: 24),
                              ),
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppColors.neonGreen,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.welcomeBack, style: AppTypography.caption),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text('Алекс Трейдер', style: AppTypography.bodyLarge.copyWith(fontSize: 15)),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified_rounded, color: AppColors.neonGreen, size: 15),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 18),
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(19),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(19),
                        onTap: onLanguageToggle,
                        child: Row(
                          children: [
                            const Icon(Icons.language, color: AppColors.neonGreen, size: 16),
                            const SizedBox(width: 4),
                            Text(langLabel, style: AppTypography.bodyLarge.copyWith(fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Баланс считается из кошелька и живых цен рынка
            Builder(
              builder: (context) {
                final wallet = context.watch<WalletCubit>().state;
                final market = context.watch<MarketCubit>().state;

                // Доллары + USDT (стоит $1) + все монеты по текущим ценам
                double total = wallet.usdBalance + wallet.getAssetBalance('USDT');
                double btcPrice = 0;

                if (market is MarketLoaded) {
                  for (final asset in market.assets) {
                    total += wallet.getAssetBalance(asset.symbol) * asset.price;
                    if (asset.symbol == 'BTC') btcPrice = asset.price;
                  }
                }

                final btcEquivalent = btcPrice > 0 ? total / btcPrice : 0.0;

                return WalletSummaryCard(totalUsd: total, btcEquivalent: btcEquivalent);
              },
            ),

            const SizedBox(height: 24),

            // Блок рынка
            BlocBuilder<MarketCubit, MarketState>(
              builder: (context, state) {
                if (state is MarketLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(color: AppColors.neonGreen),
                    ),
                  );
                }

                if (state is MarketError) {
                  return Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        Text(l10n.marketLoadError, style: AppTypography.bodyLarge),
                        const SizedBox(height: 12),
                        TextButton(onPressed: () => context.read<MarketCubit>().loadMarket(), child: Text(l10n.retry)),
                      ],
                    ),
                  );
                }

                if (state is MarketLoaded) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.massiveGrowth, style: AppTypography.titleLarge),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(color: AppColors.neonGreen, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 6),
                              Text(l10n.liveUpdates, style: AppTypography.caption.copyWith(color: AppColors.neonGreen)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      MarketHeroCard(
                        asset: state.selectedAsset,
                        allAssets: state.assets,
                        onAssetSelected: (selected) => context.read<MarketCubit>().selectAsset(selected),
                      ),

                      const SizedBox(height: 24),

                      MarketOverviewSection(
                        assets: state.assets,
                        onAssetTap: (selected) => context.read<MarketCubit>().selectAsset(selected),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
