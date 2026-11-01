import 'package:flutter_bloc/flutter_bloc.dart';

part 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  static const int _micro = 1000000;
  static const int _maxTransactions = 100;

  WalletCubit()
    : super(
        WalletState(
          usdBalanceCents: 8492050, // Старт: $84,920.50
          portfolioMicro: {'BTC': 1284502, 'ETH': 5200000, 'SOL': 58000000, 'USDT': 5100000000},
          transactions: [
            TransactionModel(
              type: TxType.buy,
              symbol: 'BTC',
              amount: 0.05,
              usd: 3306.00,
              time: DateTime.now().subtract(const Duration(hours: 2)),
            ),
            TransactionModel(
              type: TxType.reward,
              symbol: 'SOL',
              amount: 1.45,
              usd: 215.76,
              time: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
            ),
          ],
        ),
      );

  // Применяем изменения баланса и кладём новую операцию наверх истории
  void _commit({int? usdCents, Map<String, int>? portfolio, required TransactionModel tx}) {
    final all = [tx, ...state.transactions];
    emit(
      state.copyWith(
        usdBalanceCents: usdCents,
        portfolioMicro: portfolio,
        transactions: all.length > _maxTransactions ? all.sublist(0, _maxTransactions) : all,
      ),
    );
  }

  // Пополнение: в долларах (symbol = 'USD') или в монете
  bool deposit(String symbol, double amount, {required double usdPrice}) {
    if (symbol == 'USD') {
      final cents = (amount * 100).round();
      if (cents <= 0) return false;
      _commit(
        usdCents: state.usdBalanceCents + cents,
        tx: TransactionModel(type: TxType.depositUsd, symbol: 'USD', amount: cents / 100, usd: cents / 100, time: DateTime.now()),
      );
      return true;
    }

    final micro = (amount * _micro).round();
    if (micro <= 0) return false;
    final portfolio = Map<String, int>.from(state.portfolioMicro);
    portfolio[symbol] = (portfolio[symbol] ?? 0) + micro;
    _commit(
      portfolio: portfolio,
      tx: TransactionModel(
        type: TxType.depositCrypto,
        symbol: symbol,
        amount: micro / _micro,
        usd: micro / _micro * usdPrice,
        time: DateTime.now(),
      ),
    );
    return true;
  }

  // Вывод долларов
  bool withdraw(double amount) {
    final cents = (amount * 100).round();
    if (cents <= 0 || cents > state.usdBalanceCents) return false;
    _commit(
      usdCents: state.usdBalanceCents - cents,
      tx: TransactionModel(type: TxType.withdrawUsd, symbol: 'USD', amount: cents / 100, usd: cents / 100, time: DateTime.now()),
    );
    return true;
  }

  // Перевод монеты наружу: комиссия сети списывается с долларового баланса
  bool transfer(String symbol, double amount, {required double usdPrice, double fee = 1.0}) {
    final micro = (amount * _micro).round();
    final feeCents = (fee * 100).round();
    final held = state.portfolioMicro[symbol] ?? 0;
    if (micro <= 0 || micro > held || feeCents > state.usdBalanceCents) return false;

    final portfolio = Map<String, int>.from(state.portfolioMicro);
    portfolio[symbol] = held - micro;
    _commit(
      usdCents: state.usdBalanceCents - feeCents,
      portfolio: portfolio,
      tx: TransactionModel(
        type: TxType.transfer,
        symbol: symbol,
        amount: micro / _micro,
        usd: micro / _micro * usdPrice,
        fee: feeCents / 100,
        time: DateTime.now(),
      ),
    );
    return true;
  }

  // Покупка монеты за доллары (из формы на вкладке «Торговля» и из окна «Обмен»)
  bool buyAsset(String symbol, double amount, double priceUsd) {
    final micro = (amount * _micro).round();
    if (micro <= 0 || priceUsd <= 0) return false;

    final qty = micro / _micro;
    // Покупатель платит не меньше цены: округляем вверх (1e-9 убирает шум дробных чисел)
    var costCents = (qty * priceUsd * 100 - 1e-9).ceil();
    if (costCents < 1) costCents = 1;
    if (costCents > state.usdBalanceCents) return false;

    final portfolio = Map<String, int>.from(state.portfolioMicro);
    portfolio[symbol] = (portfolio[symbol] ?? 0) + micro;
    _commit(
      usdCents: state.usdBalanceCents - costCents,
      portfolio: portfolio,
      tx: TransactionModel(type: TxType.buy, symbol: symbol, amount: qty, usd: costCents / 100, time: DateTime.now()),
    );
    return true;
  }

  // Продажа монеты за доллары
  bool sellAsset(String symbol, double amount, double priceUsd) {
    final micro = (amount * _micro).round();
    if (micro <= 0 || priceUsd <= 0) return false;

    final held = state.portfolioMicro[symbol] ?? 0;
    if (held < micro) return false;

    final qty = micro / _micro;
    // Продавец получает не больше цены: округляем вниз
    final earnedCents = (qty * priceUsd * 100 + 1e-9).floor();

    final portfolio = Map<String, int>.from(state.portfolioMicro);
    portfolio[symbol] = held - micro;
    _commit(
      usdCents: state.usdBalanceCents + earnedCents,
      portfolio: portfolio,
      tx: TransactionModel(type: TxType.sell, symbol: symbol, amount: qty, usd: earnedCents / 100, time: DateTime.now()),
    );
    return true;
  }
}
