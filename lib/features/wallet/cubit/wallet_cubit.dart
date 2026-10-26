import 'package:flutter_bloc/flutter_bloc.dart';

part 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit()
    : super(
        WalletState(
          usdBalanceCents: 8492050, // Старт: $84,920.50
          portfolioMicro: {'BTC': 1284502, 'ETH': 5200000, 'SOL': 58000000, 'USDT': 5100000000},
          transactions: [
            TransactionModel(
              title: 'BTC Limit Buy',
              subtitle: 'Today, 14:32 • Completed',
              amount: r'-$3,306.00',
              isIncome: false,
              date: 'Today',
            ),
            TransactionModel(
              title: 'Staking Rewards',
              subtitle: 'Yesterday • SOL Vault',
              amount: r'+1.45 SOL',
              isIncome: true,
              date: 'Yesterday',
            ),
          ],
        ),
      );

  // Покупка актива
  bool buyAsset(String symbol, double amountDouble, double priceUsdDouble) {
    int amountMicro = (amountDouble * 1000000).round();
    int priceCents = (priceUsdDouble * 100).round();
    int totalCostCents = (amountMicro * priceCents) ~/ 1000000;

    if (state.usdBalanceCents >= totalCostCents) {
      final newBalance = state.usdBalanceCents - totalCostCents;

      final newPortfolio = Map<String, int>.from(state.portfolioMicro);
      newPortfolio[symbol] = (newPortfolio[symbol] ?? 0) + amountMicro;

      final newTransactions = List<TransactionModel>.from(state.transactions);
      newTransactions.insert(
        0,
        TransactionModel(
          title: '$symbol Limit Buy',
          subtitle: 'Just now • Completed',
          amount: '+$amountDouble $symbol',
          isIncome: true,
          date: 'Today',
        ),
      );

      emit(state.copyWith(usdBalanceCents: newBalance, portfolioMicro: newPortfolio, transactions: newTransactions));
      return true;
    }
    return false;
  }

  // Продажа актива
  bool sellAsset(String symbol, double amountDouble, double priceUsdDouble) {
    int amountMicro = (amountDouble * 1000000).round();
    int currentMicro = state.portfolioMicro[symbol] ?? 0;

    if (currentMicro >= amountMicro) {
      final newPortfolio = Map<String, int>.from(state.portfolioMicro);
      newPortfolio[symbol] = currentMicro - amountMicro;

      int priceCents = (priceUsdDouble * 100).round();
      int earnedCents = (amountMicro * priceCents) ~/ 1000000;
      final newBalance = state.usdBalanceCents + earnedCents;

      double earnedUsd = earnedCents / 100.0;

      final newTransactions = List<TransactionModel>.from(state.transactions);
      newTransactions.insert(
        0,
        TransactionModel(
          title: '$symbol Limit Sell',
          subtitle: 'Just now • Completed',
          amount: '+\$$earnedUsd',
          isIncome: true,
          date: 'Today',
        ),
      );

      emit(state.copyWith(usdBalanceCents: newBalance, portfolioMicro: newPortfolio, transactions: newTransactions));
      return true;
    }
    return false;
  }
}
