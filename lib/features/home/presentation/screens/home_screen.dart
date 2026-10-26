import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/core/widgets/base_screen_layout.dart';
import 'package:bittarget/features/home/data/crypto_api_service.dart';
import 'package:bittarget/features/wallet/wallet_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/market_cubit.dart';

import '../widgets/market_hero_card.dart';
import '../widgets/market_overview_section.dart';

class HomeScreen extends StatelessWidget {
  final bool isEnglish;
  final VoidCallback onLanguageToggle;
  final VoidCallback onProfileTap;

  const HomeScreen({super.key, required this.isEnglish, required this.onLanguageToggle, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MarketCubit(CryptoApiService())..loadMarket(),
      child: BaseScreenLayout(
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
                                Text(isEnglish ? 'Welcome back,' : 'Добро пожаловать,', style: AppTypography.caption),
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
                              Text(isEnglish ? 'EN' : 'RU', style: AppTypography.bodyLarge.copyWith(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // БАЛАНС ЧЕЛОВЕКА СВЕРХУ (как на макете!)
              const WalletSummaryCard(isEnglish: true, totalUsd: 84920.50, btcEquivalent: 1.284502),

              const SizedBox(height: 24),

              // БЛОК РЫНКА С ДАННЫМИ С БЭКА
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

                  if (state is MarketLoaded) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(isEnglish ? 'MASSIVE GROWTH TODAY' : 'МАСШТАБНЫЙ РОСТ СЕГОДНЯ', style: AppTypography.titleLarge),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(color: AppColors.neonGreen, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isEnglish ? 'Live updates' : 'В реальном времени',
                                  style: AppTypography.caption.copyWith(color: AppColors.neonGreen),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ГЛАВНЫЙ ГРАФИК АКТИВА (С ВЫБОРОМ ЛЮБОЙ ИЗ 15 МОНЕТ)
                        MarketHeroCard(
                          isEnglish: isEnglish,
                          asset: state.selectedAsset,
                          allAssets: state.assets,
                          onAssetSelected: (selected) {
                            context.read<MarketCubit>().selectAsset(selected);
                          },
                        ),

                        const SizedBox(height: 24),

                        // ОБЗОР РЫНКА С ИКОНКАМИ И ЦЕНАМИ С БАЙНАНСА
                        MarketOverviewSection(
                          isEnglish: isEnglish,
                          assets: state.assets,
                          onAssetTap: (selected) {
                            context.read<MarketCubit>().selectAsset(selected);
                          },
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
      ),
    );
  }
}
