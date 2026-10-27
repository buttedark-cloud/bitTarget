import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => _showAssetSelector(context),
                child: Row(
                  children: [
                    Image.network(
                      asset.iconUrl,
                      width: 36,
                      height: 36,
                      errorBuilder: (_, __, ___) => const Icon(Icons.currency_bitcoin, color: AppColors.neonGreen),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(isEn ? asset.nameEn : asset.nameRu, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, color: AppColors.neonGreen),
                          ],
                        ),
                        Text(asset.pair, style: AppTypography.caption),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: asset.isPositive ? AppColors.neonGreen : AppColors.neonRed,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${asset.isPositive ? '+' : ''}${asset.changePercent.toStringAsFixed(2)}%',
                  style: AppTypography.badgeGreen.copyWith(color: Colors.black, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('\$${asset.price.toStringAsFixed(2)}', style: AppTypography.displayLarge.copyWith(fontSize: 32, color: Colors.white)),
          const SizedBox(height: 4),
          Text(l10n.realtimeBinance, style: AppTypography.caption),
          const SizedBox(height: 16),
          SizedBox(
            height: 70,
            width: double.infinity,
            child: CustomPaint(painter: NeonChartPainter(asset.sparkline, asset.isPositive)),
          ),
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
                      leading: Image.network(item.iconUrl, width: 30, height: 30, errorBuilder: (_, __, ___) => const SizedBox()),
                      title: Text(isEn ? item.nameEn : item.nameRu, style: AppTypography.bodyLarge),
                      subtitle: Text(item.pair, style: AppTypography.caption),
                      trailing: Text('\$${item.price.toStringAsFixed(2)}', style: AppTypography.bodyLarge),
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

class NeonChartPainter extends CustomPainter {
  final List<double> points;
  final bool isPositive;

  NeonChartPainter(this.points, this.isPositive);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final color = isPositive ? AppColors.neonGreen : AppColors.neonRed;

    final paintLine = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final minVal = points.reduce((a, b) => a < b ? a : b);
    final maxVal = points.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal == 0 ? 1 : maxVal - minVal;

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height - ((points[i] - minVal) / range) * size.height * 0.8 - 5;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
