import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/core/widgets/base_screen_layout.dart';
import 'package:bittarget/features/trade/data/trade_service.dart';
import 'package:bittarget/features/trade/presentation/cubit/trade_cubit.dart';
import 'package:bittarget/features/trade/presentation/widgets/trade_chart_section.dart';
import 'package:bittarget/features/trade/presentation/widgets/trade_header.dart';
import 'package:bittarget/features/trade/presentation/widgets/trade_order_section.dart';
import 'package:bittarget/features/trade/presentation/widgets/trade_sheets.dart';
import 'package:bittarget/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TradeScreen extends StatefulWidget {
  // true, когда открыта именно вкладка «Торговля»
  final bool isActive;

  const TradeScreen({super.key, this.isActive = true});

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  late final TradeCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = TradeCubit(TradeService(), active: widget.isActive)..load();
  }

  @override
  void didUpdateWidget(covariant TradeScreen old) {
    super.didUpdateWidget(old);
    if (old.isActive != widget.isActive) _cubit.setActive(widget.isActive);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BaseScreenLayout(child: const _TradeBody()),
    );
  }
}

enum _Mode { loading, error, content }

_Mode _modeOf(TradeState s) => s.ticker != null ? _Mode.content : (s.status == TradeStatus.error ? _Mode.error : _Mode.loading);

// Верхний уровень перерисовывается, только когда экран переходит между загрузкой, ошибкой и данными
class _TradeBody extends StatelessWidget {
  const _TradeBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<TradeCubit, TradeState>(
      builder: (context, state) {
        final mode = _modeOf(state);

        switch (mode) {
          case _Mode.error:
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.marketLoadError, style: AppTypography.bodyLarge),
                    const SizedBox(height: 8),
                    SelectableText(state.error ?? '', textAlign: TextAlign.center, style: AppTypography.caption.copyWith(fontSize: 11)),
                    const SizedBox(height: 12),
                    TextButton(onPressed: () => context.read<TradeCubit>().load(), child: Text(l10n.retry)),
                  ],
                ),
              ),
            );
          case _Mode.loading:
            return const Center(child: CircularProgressIndicator(color: AppColors.neonGreen));
          case _Mode.content:
            return const _TradeContent();
        }
      },
    );
  }
}

class _TradeContent extends StatelessWidget {
  const _TradeContent();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TradeCubit>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Шапка: только при новой цене, смене монеты или избранного
          BlocBuilder<TradeCubit, TradeState>(
            buildWhen: (p, c) => p.ticker != c.ticker || p.favorites != c.favorites || p.symbol != c.symbol,
            builder: (context, s) {
              final ticker = s.ticker;
              if (ticker == null) return const SizedBox.shrink();
              return TradeHeader(
                pair: '${s.symbol}/USDT',
                isFavorite: s.favorites.contains(s.symbol),
                ticker: ticker,
                onPairTap: () => showPairSelector(context, cubit),
                onFavoriteTap: () => cubit.toggleFavorite(s.symbol),
                onSettingsTap: () => showChartSettings(context, cubit),
              );
            },
          ),
          const SizedBox(height: 16),
          // График: только при новых свечах, смене таймфрейма и настроек
          BlocBuilder<TradeCubit, TradeState>(
            buildWhen: (p, c) =>
                p.candles != c.candles ||
                p.interval != c.interval ||
                p.status != c.status ||
                p.showMa != c.showMa ||
                p.showDots != c.showDots,
            builder: (_, s) => RepaintBoundary(child: TradeChartSection(state: s)),
          ),
          const SizedBox(height: 16),
          const TradeOrderSection(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
