import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/core/utils/format.dart';
import 'package:bittarget/features/trade/data/trade_models.dart';
import 'package:bittarget/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class TradeHeader extends StatelessWidget {
  final String pair;
  final TickerData ticker;

  const TradeHeader({super.key, required this.pair, required this.ticker});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final positive = ticker.changePercent >= 0;
    final accent = positive ? AppColors.neonGreen : AppColors.neonRed;
    final sign = positive ? '+' : '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(pair, style: AppTypography.titleLarge),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColors.neonGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
              child: Text('10X', style: AppTypography.badgeGreen.copyWith(fontSize: 10)),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
            const Spacer(),
            const Icon(Icons.star_border_rounded, color: Color(0xFFFFB800), size: 22),
            const SizedBox(width: 14),
            const Icon(Icons.tune_rounded, color: AppColors.textSecondary, size: 22),
          ],
        ),
        const SizedBox(height: 14),
        Container(height: 1, color: Colors.white.withValues(alpha: 0.08)),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(formatUsd(ticker.price), style: AppTypography.displayLarge.copyWith(fontSize: 30, color: accent)),
                const SizedBox(height: 4),
                Text(
                  '$sign${formatUsd(ticker.change.abs())} ( $sign${ticker.changePercent.abs().toStringAsFixed(2)}% )',
                  style: AppTypography.caption.copyWith(color: accent, fontSize: 12),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [_stat(l10n.high24h, ticker.high), const SizedBox(height: 6), _stat(l10n.low24h, ticker.low)],
            ),
          ],
        ),
      ],
    );
  }

  Widget _stat(String label, double value) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '$label: ', style: AppTypography.caption),
          TextSpan(
            text: formatUsd(value),
            style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
