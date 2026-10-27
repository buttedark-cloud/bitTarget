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

class MarketHeroCard extends StatelessWidget {
  final CryptoAsset asset;
  final List<CryptoAsset> allAssets;
  final ValueChanged<CryptoAsset> onAssetSelected;

  const MarketHeroCard({super.key, required this.asset, required this.allAssets, required this.onAssetSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final accent = asset.isPositive ? AppColors.neonGreen : AppColors.neonRed;

    return GlassCard(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: PressEffect(
                    onTap: () => _showAssetSelector(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CoinIcon(symbol: asset.symbol, size: 46),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      isEn ? asset.nameEn : asset.nameRu,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.bodyLarge.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(asset.symbol, style: AppTypography.caption),
                                  const Icon(Icons.arrow_drop_down, color: AppColors.neonGreen),
                                ],
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  formatUsd(asset.price),
                                  style: AppTypography.displayMedium.copyWith(fontSize: 22, color: accent),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      '${asset.isPositive ? '+' : '-'}${asset.changePercent.toStringAsFixed(2)}%',
                      style: AppTypography.badgeGreen.copyWith(color: Colors.black, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('${l10n.high24h}: ${formatUsd(asset.high24h)}', style: AppTypography.caption),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          NeonChart(points: asset.sparkline, isPositive: asset.isPositive, height: 90),
        ],
      ),
    );
  }

  void _showAssetSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEn = Localizations.localeOf(context).languageCode == 'en';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121214),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.selectAsset, style: AppTypography.titleLarge),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: allAssets.length,
                  itemBuilder: (_, index) {
                    final item = allAssets[index];
                    return ListTile(
                      leading: CoinIcon(symbol: item.symbol, size: 32),
                      title: Text(isEn ? item.nameEn : item.nameRu, style: AppTypography.bodyLarge),
                      subtitle: Text(item.pair, style: AppTypography.caption),
                      trailing: Text(formatUsd(item.price), style: AppTypography.bodyLarge),
                      onTap: () {
                        onAssetSelected(item);
                        Navigator.pop(sheetContext);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
