import 'package:bittarget/core/utils/format.dart';
import 'package:bittarget/features/home/data/crypto_asset_model.dart';
import 'package:bittarget/features/wallet/cubit/wallet_cubit.dart';
import 'package:bittarget/features/wallet/portfolio.dart';
import 'package:flutter_test/flutter_test.dart';

CryptoAsset asset(String symbol, double price, {double change = 0, bool up = true}) {
  return CryptoAsset(
    symbol: symbol,
    nameRu: symbol,
    nameEn: symbol,
    pair: '$symbol/USDT',
    price: price,
    changePercent: change,
    isPositive: up,
    high24h: price,
    sparkline: const [],
  );
}

void main() {
  group('Портфель', () {
    test('общая стоимость: доллары + монеты по цене + USDT по курсу 1 доллар', () {
      const wallet = WalletState(
        usdBalanceCents: 100000, // $1000
        portfolioMicro: {'BTC': 500000, 'USDT': 100000000}, // 0.5 BTC и 100 USDT
        transactions: [],
      );
      final snap = buildPortfolio(wallet, [asset('BTC', 60000)]);

      expect(snap.netWorth, closeTo(31100, 1e-6)); // 1000 + 30000 + 100
      expect(snap.pnl24h, closeTo(0, 1e-9));
      expect(snap.items.map((i) => i.symbol).toList(), ['BTC', 'USD', 'USDT']); // от большего к меньшему
    });

    test('прибыль за 24 часа при росте на 10%', () {
      const wallet = WalletState(usdBalanceCents: 0, portfolioMicro: {'BTC': 1000000}, transactions: []);
      final snap = buildPortfolio(wallet, [asset('BTC', 110, change: 10)]);

      expect(snap.netWorth, closeTo(110, 1e-9));
      expect(snap.pnl24h, closeTo(10, 1e-6)); // вчера 100, сегодня 110
    });

    test('убыток за 24 часа при падении на 10%', () {
      const wallet = WalletState(usdBalanceCents: 0, portfolioMicro: {'BTC': 1000000}, transactions: []);
      final snap = buildPortfolio(wallet, [asset('BTC', 90, change: 10, up: false)]);

      expect(snap.pnl24h, closeTo(-10, 1e-6)); // вчера 100, сегодня 90
    });

    test('доли активов в сумме дают 100%', () {
      const wallet = WalletState(usdBalanceCents: 100000, portfolioMicro: {'BTC': 500000, 'ETH': 2000000}, transactions: []);
      final snap = buildPortfolio(wallet, [asset('BTC', 60000), asset('ETH', 3000)]);

      final sum = snap.items.fold<double>(0, (s, i) => s + i.fraction);
      expect(sum, closeTo(1.0, 1e-9));
    });

    test('монета, которой нет на рынке, не ломает расчёт', () {
      const wallet = WalletState(usdBalanceCents: 100000, portfolioMicro: {'XYZ': 5000000}, transactions: []);
      final snap = buildPortfolio(wallet, [asset('BTC', 60000)]);

      expect(snap.netWorth, closeTo(1000, 1e-9));
      expect(snap.items.map((i) => i.symbol).toList(), ['USD']);
    });

    test('таблица цен содержит USDT по курсу 1 доллар', () {
      final prices = priceMap([asset('BTC', 100)]);
      expect(prices['USDT'], 1.0);
      expect(prices['BTC'], 100);
    });
  });

  group('Форматирование цен', () {
    test('обычные цены с запятыми и двумя знаками', () {
      expect(formatUsd(80520.01), r'$80,520.01');
      expect(formatUsd(1234.5), r'$1,234.50');
      expect(formatUsd(1), r'$1.00');
    });

    test('ноль показывается как 0.00 доллара', () {
      expect(formatUsd(0), r'$0.00');
      expect(formatPrice(0), '0.00');
    });

    test('у дешёвых монет больше знаков', () {
      expect(formatUsd(0.0914), r'$0.0914');
      expect(formatUsd(0.000012), r'$0.000012');
      expect(formatPrice(0.5), '0.5000');
    });

    test('formatPrice без знака доллара и запятых', () {
      expect(formatPrice(80520.01), '80520.01');
      expect(formatPrice(12.345678), '12.35');
    });
  });
}
