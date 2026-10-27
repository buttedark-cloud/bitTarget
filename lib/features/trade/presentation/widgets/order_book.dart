import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/core/utils/format.dart';
import 'package:bittarget/core/widgets/press_effect.dart';
import 'package:bittarget/features/trade/data/trade_models.dart';
import 'package:bittarget/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class OrderBookView extends StatelessWidget {
  final OrderBook? book;
  final double lastPrice;
  final bool isUp;
  final ValueChanged<double> onPriceTap;

  const OrderBookView({super.key, required this.book, required this.lastPrice, required this.isUp, required this.onPriceTap});

  static const int _rows = 5;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final b = book;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.orderBookPrice, style: AppTypography.caption),
              Text(l10n.orderBookSize, style: AppTypography.caption),
            ],
          ),
        ),
        const SizedBox(height: 6),
        if (b == null)
          const SizedBox(
            height: 260,
            child: Center(
              child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.neonGreen, strokeWidth: 2)),
            ),
          )
        else
          ..._buildBook(b),
      ],
    );
  }

  List<Widget> _buildBook(OrderBook b) {
    // Продажи: самая высокая цена сверху, лучшая цена рядом с серединой
    final asks = b.asks.take(_rows).toList().reversed.toList();
    final bids = b.bids.take(_rows).toList();

    var maxQty = 0.0;
    for (final l in [...asks, ...bids]) {
      if (l.qty > maxQty) maxQty = l.qty;
    }

    final midColor = isUp ? AppColors.neonGreen : AppColors.neonRed;

    return [
      for (final l in asks) _level(l, maxQty, AppColors.neonRed),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Text(
            formatPrice(lastPrice),
            style: AppTypography.bodyLarge.copyWith(fontSize: 16, fontWeight: FontWeight.w800, color: midColor),
          ),
        ),
      ),
      for (final l in bids) _level(l, maxQty, AppColors.neonGreen),
    ];
  }

  Widget _level(OrderBookLevel level, double maxQty, Color color) {
    final factor = maxQty == 0 ? 0.0 : (level.qty / maxQty).clamp(0.05, 1.0).toDouble();

    return PressEffect(
      scale: 0.98,
      onTap: () => onPriceTap(level.price),
      child: SizedBox(
        height: 26,
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: factor,
                    child: Container(
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(3)),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formatPrice(level.price),
                    style: AppTypography.caption.copyWith(fontSize: 12, color: color, fontWeight: FontWeight.w600),
                  ),
                  Text(_qty(level.qty), style: AppTypography.caption.copyWith(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _qty(double q) {
    if (q >= 1000) return q.toStringAsFixed(0);
    if (q >= 1) return q.toStringAsFixed(2);
    return q.toStringAsFixed(3);
  }
}
