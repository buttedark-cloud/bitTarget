import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/core/widgets/base_screen_layout.dart';
import 'package:bittarget/core/widgets/press_effect.dart';
import 'package:bittarget/features/trade/data/trade_service.dart';
import 'package:bittarget/features/trade/presentation/cubit/trade_cubit.dart';
import 'package:bittarget/features/trade/presentation/widgets/trade_chart_section.dart';
import 'package:bittarget/features/trade/presentation/widgets/trade_header.dart';
import 'package:bittarget/features/trade/presentation/widgets/trade_order_section.dart';
import 'package:bittarget/features/trade/presentation/widgets/trade_sheets.dart';
import 'package:bittarget/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bittarget/core/network/api_client.dart';
import 'package:bittarget/core/network/api_error_text.dart';

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
      child: const BaseScreenLayout(child: _TradeBody()),
    );
  }
}

enum _Mode { loading, error, content }

_Mode _modeOf(TradeState s) => s.ticker != null ? _Mode.content : (s.status == TradeStatus.error ? _Mode.error : _Mode.loading);

class _TradeBody extends StatelessWidget {
  const _TradeBody();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<TradeCubit, TradeState>(
      builder: (context, state) {
        switch (_modeOf(state)) {
          case _Mode.error:
            return _StatusView(
              symbol: state.symbol,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, color: AppColors.textSecondary, size: 40),
                    const SizedBox(height: 12),
                    Text(l10n.marketLoadError, style: AppTypography.bodyLarge),
                    const SizedBox(height: 8),
                    Text(
                      apiErrorText(l10n, state.errorKind ?? ApiErrorKind.unknown),
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 12),
                    TextButton(onPressed: () => context.read<TradeCubit>().load(), child: Text(l10n.retry)),
                  ],
                ),
              ),
            );
          case _Mode.loading:
            return _StatusView(
              symbol: state.symbol,
              child: const CircularProgressIndicator(color: AppColors.neonGreen),
            );
          case _Mode.content:
            return const _TradeContent();
        }
      },
    );
  }
}

// Экран загрузки или ошибки: сверху всегда кнопка выбора монеты,
// чтобы можно было переключиться, не дожидаясь результата
class _StatusView extends StatelessWidget {
  final String symbol;
  final Widget child;

  const _StatusView({required this.symbol, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PressEffect(
            scale: 0.97,
            onTap: () => showPairSelector(context, context.read<TradeCubit>()),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Text('$symbol/USDT', style: AppTypography.titleLarge),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.neonGreen),
                ],
              ),
            ),
          ),
          Expanded(child: Center(child: child)),
        ],
      ),
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
          const _ConnectionBanner(),
          const SizedBox(height: 16),
          // График: только при новых свечах, смене таймфрейма, настроек и ошибке
          BlocBuilder<TradeCubit, TradeState>(
            buildWhen: (p, c) =>
                p.candles != c.candles ||
                p.interval != c.interval ||
                p.status != c.status ||
                p.showMa != c.showMa ||
                p.showDots != c.showDots ||
                p.chartError != c.chartError,
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

// Полоска «Переподключение…»: видна, только пока живая связь потеряна
class _ConnectionBanner extends StatelessWidget {
  const _ConnectionBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<TradeCubit, TradeState>(
      buildWhen: (p, c) => p.live != c.live,
      builder: (_, s) => AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: s.live == LiveStatus.reconnecting
            ? Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB800).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFB800).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFB800))),
                      const SizedBox(width: 10),
                      Text(l10n.reconnecting, style: AppTypography.caption.copyWith(fontSize: 11, color: Colors.white70)),
                    ],
                  ),
                ),
              )
            : const SizedBox(width: double.infinity),
      ),
    );
  }
}
