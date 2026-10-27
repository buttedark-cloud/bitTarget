import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/core/widgets/base_screen_layout.dart';
import 'package:bittarget/features/trade/data/trade_service.dart';
import 'package:bittarget/features/trade/presentation/cubit/trade_cubit.dart';
import 'package:bittarget/features/trade/presentation/widgets/trade_chart_section.dart';
import 'package:bittarget/features/trade/presentation/widgets/trade_header.dart';
import 'package:bittarget/features/trade/presentation/widgets/trade_order_section.dart';
import 'package:bittarget/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TradeScreen extends StatelessWidget {
  const TradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => TradeCubit(TradeService())..load(),
      child: BaseScreenLayout(
        child: BlocBuilder<TradeCubit, TradeState>(
          builder: (context, state) {
            final cubit = context.read<TradeCubit>();

            if (state.status == TradeStatus.error && state.ticker == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.marketLoadError, style: AppTypography.bodyLarge),
                    const SizedBox(height: 12),
                    TextButton(onPressed: () => cubit.load(), child: Text(l10n.retry)),
                  ],
                ),
              );
            }

            if (state.ticker == null) {
              return const Center(child: CircularProgressIndicator(color: AppColors.neonGreen));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TradeHeader(pair: cubit.pair, ticker: state.ticker!),
                  const SizedBox(height: 16),
                  TradeChartSection(state: state),
                  const SizedBox(height: 16),
                  TradeOrderSection(state: state, symbol: cubit.symbol),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
