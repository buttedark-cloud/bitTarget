import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
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
            return GestureDetector(
              onTap: () => onAssetTap(asset),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.network(
                          asset.iconUrl,
                          width: 36,
                          height: 36,
                          errorBuilder: (_, __, ___) => const Icon(Icons.currency_bitcoin, color: AppColors.neonGreen),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isEn ? asset.nameEn : asset.nameRu, style: AppTypography.bodyLarge),
                            const SizedBox(height: 2),
                            Text(asset.pair, style: AppTypography.caption),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('\$${asset.price.toStringAsFixed(2)}', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(
                          '${asset.isPositive ? '+' : ''}${asset.changePercent.toStringAsFixed(2)}%',
                          style: AppTypography.caption.copyWith(
                            color: asset.isPositive ? AppColors.neonGreen : AppColors.neonRed,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
