import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/core/widgets/glass_card.dart';
import 'package:bittarget/core/widgets/press_effect.dart';
import 'package:bittarget/features/trade/presentation/cubit/trade_cubit.dart';
import 'package:bittarget/features/trade/presentation/widgets/trade_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TradeChartSection extends StatefulWidget {
  final TradeState state;

  const TradeChartSection({super.key, required this.state});

  @override
  State<TradeChartSection> createState() => _TradeChartSectionState();
}

class _TradeChartSectionState extends State<TradeChartSection> {
  bool _showMa = false;

  // (значение для Binance, подпись на экране)
  static const _intervals = [('15m', '15m'), ('1h', '1h'), ('4h', '4h'), ('1d', '1D')];

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final candles = state.candles;
    final isUp = candles.length < 2 || candles.last.close >= candles.first.close;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                for (final (value, label) in _intervals)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: PressEffect(
                      onTap: () => context.read<TradeCubit>().selectInterval(value),
                      child: Text(
                        label,
                        style: AppTypography.bodyLarge.copyWith(
                          fontSize: 13,
                          color: state.interval == value ? AppColors.neonGreen : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Row(
              children: [
                _chip('MA', active: _showMa, onTap: () => setState(() => _showMa = !_showMa)),
                const SizedBox(width: 6),
                _chip('RSI', enabled: false),
                const SizedBox(width: 6),
                _chip('MACD', enabled: false),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        GlassCard(
          radius: 16,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Stack(
            alignment: Alignment.center,
            children: [
              TradeChart(candles: candles, isUp: isUp, showMa: _showMa, interval: state.interval),
              if (state.status == TradeStatus.loading)
                const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(color: AppColors.neonGreen, strokeWidth: 2)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, {bool active = false, bool enabled = true, VoidCallback? onTap}) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: PressEffect(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: active ? AppColors.neonGreen.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: active ? AppColors.neonGreen : Colors.white.withValues(alpha: 0.12)),
          ),
          child: Text(
            label,
            style: AppTypography.caption.copyWith(color: active ? AppColors.neonGreen : Colors.white70, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
