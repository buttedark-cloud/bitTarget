part of 'wallet_cubit.dart';

class TransactionModel {
  final String title;
  final String subtitle;
  final String amount;
  final bool isIncome;
  final String date;

  TransactionModel({required this.title, required this.subtitle, required this.amount, required this.isIncome, required this.date});
}

class WalletState {
  final int usdBalanceCents;
  final Map<String, int> portfolioMicro;
  final List<TransactionModel> transactions;

  const WalletState({required this.usdBalanceCents, required this.portfolioMicro, required this.transactions});

  // Удобные геттеры для UI (безопасный перевод из int)
  double get usdBalance => usdBalanceCents / 100.0;

  double getAssetBalance(String symbol) {
    int microAmount = portfolioMicro[symbol] ?? 0;
    return microAmount / 1000000.0;
  }

  // Копирование состояния для обновления
  WalletState copyWith({int? usdBalanceCents, Map<String, int>? portfolioMicro, List<TransactionModel>? transactions}) {
    return WalletState(
      usdBalanceCents: usdBalanceCents ?? this.usdBalanceCents,
      portfolioMicro: portfolioMicro ?? this.portfolioMicro,
      transactions: transactions ?? this.transactions,
    );
  }
}
