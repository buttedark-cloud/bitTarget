import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/core/utils/format.dart';
import 'package:bittarget/core/widgets/press_effect.dart';
import 'package:bittarget/features/trade/data/trade_models.dart';
import 'package:bittarget/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class TradeHeader extends StatelessWidget {
  final String pair;
  final bool isFavorite;
  final TickerData ticker;
  final VoidCallback onPairTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onSettingsTap;

  const TradeHeader({
    super.key,
    required this.pair,
    required this.isFavorite,
    required this.ticker,
    required this.onPairTap,
    required this.onFavoriteTap,
    required this.onSettingsTap,
  });

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
            // Меню, пара и стрелка открывают список монет
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: PressEffect(
                  scale: 0.97,
                  onTap: onPairTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        Text(pair, style: AppTypography.titleLarge),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.neonGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('10X', style: AppTypography.badgeGreen.copyWith(fontSize: 10)),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.neonGreen),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            PressEffect(
              onTap: onFavoriteTap,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(isFavorite ? Icons.star_rounded : Icons.star_border_rounded, color: const Color(0xFFFFB800), size: 22),
              ),
            ),
            PressEffect(
              onTap: onSettingsTap,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.tune_rounded, color: AppColors.textSecondary, size: 22),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
            const SizedBox(width: 8),
            // FittedBox уменьшает текст, если он не помещается в ширину экрана
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [_stat(l10n.high24h, ticker.high), const SizedBox(height: 6), _stat(l10n.low24h, ticker.low)],
                ),
              ),
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
