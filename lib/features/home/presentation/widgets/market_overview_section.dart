import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/core/utils/format.dart';
import 'package:bittarget/core/widgets/coin_icon.dart';
import 'package:bittarget/core/widgets/glass_card.dart';
import 'package:bittarget/core/widgets/neon_chart.dart';
import 'package:bittarget/core/widgets/press_effect.dart';
import 'package:bittarget/features/home/data/crypto_asset_model.dart';
import 'package:bittarget/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class MarketOverviewSection extends StatelessWidget {
  final List<CryptoAsset> assets;
  final ValueChanged<CryptoAsset> onAssetTap;

  const MarketOverviewSection({super.key, required this.assets, required this.onAssetTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.marketOverview.toUpperCase(), style: AppTypography.titleLarge),
            Text(l10n.vol24h, style: AppTypography.caption),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: assets.length,
          itemBuilder: (context, index) {
            final asset = assets[index];
            final color = asset.isPositive ? AppColors.neonGreen : AppColors.neonRed;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PressEffect(
                onTap: () => onAssetTap(asset),
                child: GlassCard(
                  radius: 16,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      CoinIcon(symbol: asset.symbol, size: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEn ? asset.nameEn : asset.nameRu,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(asset.pair, style: AppTypography.caption),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: NeonChart(
                            points: asset.sparkline,
                            isPositive: asset.isPositive,
                            height: 30,
                            strokeWidth: 1.8,
                            showFill: false,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(formatUsd(asset.price), style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(
                            '${asset.isPositive ? '+' : '-'}${asset.changePercent.toStringAsFixed(2)}%',
                            style: AppTypography.caption.copyWith(color: color, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
