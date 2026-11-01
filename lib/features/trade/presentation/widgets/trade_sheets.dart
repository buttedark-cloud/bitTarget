import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/core/utils/format.dart';
import 'package:bittarget/core/widgets/coin_icon.dart';
import 'package:bittarget/core/widgets/press_effect.dart';
import 'package:bittarget/features/home/data/crypto_asset_model.dart';
import 'package:bittarget/features/home/presentation/cubit/market_cubit.dart';
import 'package:bittarget/features/trade/presentation/cubit/trade_cubit.dart';
import 'package:bittarget/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _sheetShape = RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20)));

void showPairSelector(BuildContext context, TradeCubit cubit) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF121214),
    shape: _sheetShape,
    builder: (_) => BlocProvider.value(value: cubit, child: const _PairSelectorSheet()),
  );
}

void showChartSettings(BuildContext context, TradeCubit cubit) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF121214),
    shape: _sheetShape,
    builder: (_) => BlocProvider.value(value: cubit, child: const _ChartSettingsSheet()),
  );
}

class _PairSelectorSheet extends StatefulWidget {
  const _PairSelectorSheet();

  @override
  State<_PairSelectorSheet> createState() => _PairSelectorSheetState();
}

class _PairSelectorSheetState extends State<_PairSelectorSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final cubit = context.read<TradeCubit>();
    final fav = context.select((TradeCubit c) => c.state.favorites);
    final currentSymbol = context.select((TradeCubit c) => c.state.symbol);
    final market = context.watch<MarketCubit>().state;
    final all = market is MarketLoaded ? market.assets : <CryptoAsset>[];

    final q = _query.trim().toLowerCase();
    final filtered = all.where((a) {
      return q.isEmpty || a.symbol.toLowerCase().contains(q) || a.nameEn.toLowerCase().contains(q) || a.nameRu.toLowerCase().contains(q);
    }).toList();

    // Избранные сверху, остальные в обычном порядке рынка

    final items = [...filtered.where((a) => fav.contains(a.symbol)), ...filtered.where((a) => !fav.contains(a.symbol))];

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Text(l10n.selectAsset, style: AppTypography.titleLarge),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                cursorColor: AppColors.neonGreen,
                style: AppTypography.bodyLarge.copyWith(fontSize: 14),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.black.withValues(alpha: 0.35),
                  hintText: l10n.searchCoin,
                  hintStyle: AppTypography.caption.copyWith(fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.neonGreen.withValues(alpha: 0.6)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final a = items[i];
                  final selected = a.symbol == currentSymbol;
                  final color = a.isPositive ? AppColors.neonGreen : AppColors.neonRed;

                  return PressEffect(
                    scale: 0.98,
                    onTap: () {
                      cubit.selectSymbol(a.symbol);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          CoinIcon(symbol: a.symbol, size: 36),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEn ? a.nameEn : a.nameRu,
                                  style: AppTypography.bodyLarge.copyWith(color: selected ? AppColors.neonGreen : Colors.white),
                                ),
                                Text(a.pair, style: AppTypography.caption),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(formatUsd(a.price), style: AppTypography.bodyLarge.copyWith(fontSize: 13)),
                              Text(
                                '${a.isPositive ? '+' : '-'}${a.changePercent.toStringAsFixed(2)}%',
                                style: AppTypography.caption.copyWith(color: color, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          PressEffect(
                            onTap: () => cubit.toggleFavorite(a.symbol),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                fav.contains(a.symbol) ? Icons.star_rounded : Icons.star_border_rounded,
                                color: const Color(0xFFFFB800),
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartSettingsSheet extends StatelessWidget {
  const _ChartSettingsSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<TradeCubit>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
        child: BlocBuilder<TradeCubit, TradeState>(
          builder: (_, state) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.chartSettings, style: AppTypography.titleLarge),
              const SizedBox(height: 8),
              _switchRow(l10n.showPoints, state.showDots, cubit.toggleDots),
              _switchRow(l10n.showMa, state.showMa, cubit.toggleMa),
            ],
          ),
        ),
      ),
    );
  }

  Widget _switchRow(String label, bool value, VoidCallback onToggle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyLarge.copyWith(fontSize: 14)),
          Switch(
            value: value,
            onChanged: (_) => onToggle(),
            thumbColor: const WidgetStatePropertyAll(Colors.white),
            trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected) ? AppColors.neonGreen : Colors.white24,
            ),
          ),
        ],
      ),
    );
  }
}
