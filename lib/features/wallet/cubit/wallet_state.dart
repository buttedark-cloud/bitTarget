part of 'wallet_cubit.dart';

enum TxType { buy, sell, depositUsd, depositCrypto, withdrawUsd, transfer, reward }

class TransactionModel {
  final TxType type;
  final String symbol; // 'USD' для долларов
  final double amount; // количество в единицах symbol (всегда положительное)
  final double usd; // сумма в долларах
  final double fee; // комиссия в долларах
  final DateTime time;

  const TransactionModel({
    required this.type,
    required this.symbol,
    required this.amount,
    required this.usd,
    this.fee = 0,
    required this.time,
  });

  // Прибавилось ли у пользователя то, что записано в symbol
  bool get isIncome => type == TxType.buy || type == TxType.depositUsd || type == TxType.depositCrypto || type == TxType.reward;
}

class WalletState {
  final int usdBalanceCents;
  final Map<String, int> portfolioMicro;
  final List<TransactionModel> transactions;

  const WalletState({required this.usdBalanceCents, required this.portfolioMicro, required this.transactions});

  double get usdBalance => usdBalanceCents / 100.0;

  double getAssetBalance(String symbol) {
    int microAmount = portfolioMicro[symbol] ?? 0;
    return microAmount / 1000000.0;
  }

  WalletState copyWith({int? usdBalanceCents, Map<String, int>? portfolioMicro, List<TransactionModel>? transactions}) {
    return WalletState(
      usdBalanceCents: usdBalanceCents ?? this.usdBalanceCents,
      portfolioMicro: portfolioMicro ?? this.portfolioMicro,
      transactions: transactions ?? this.transactions,
    );
  }
}
