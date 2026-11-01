import 'package:bittarget/features/home/data/crypto_asset_model.dart';
import 'package:bittarget/features/wallet/cubit/wallet_cubit.dart';

/// Цены монет в долларах (USDT стоит $1, его нет в списке рынка)
Map<String, double> priceMap(List<CryptoAsset> assets) => {'USDT': 1.0, for (final a in assets) a.symbol: a.price};

/// Монеты, с которыми можно работать: USDT и все монеты рынка
List<String> coinSymbols(List<CryptoAsset> assets) => ['USDT', ...assets.map((a) => a.symbol)];

class AllocationItem {
  final String symbol; // 'USD' для долларов
  final double value;
  final double fraction;

  const AllocationItem(this.symbol, this.value, this.fraction);
}

class PortfolioSnapshot {
  final double netWorth;
  final double pnl24h;
  final List<AllocationItem> items; // от большего к меньшему

  const PortfolioSnapshot({required this.netWorth, required this.pnl24h, required this.items});
}

PortfolioSnapshot buildPortfolio(WalletState wallet, List<CryptoAsset> assets) {
  final prices = priceMap(assets);
  final changes = {for (final a in assets) a.symbol: a.isPositive ? a.changePercent : -a.changePercent};

  final values = <String, double>{'USD': wallet.usdBalance};
  var pnl = 0.0;

  wallet.portfolioMicro.forEach((symbol, micro) {
    final price = prices[symbol];
    if (price == null || micro <= 0) return;

    final value = micro / 1000000 * price;
    values[symbol] = value;

    // Сколько стоили эти монеты 24 часа назад, и на сколько изменилось
    final double pct = changes[symbol] ?? 0.0;
    pnl += value - value / (1 + pct / 100);
  });

  final total = values.values.fold<double>(0, (a, b) => a + b);
  final items = [
    for (final e in values.entries)
      if (e.value > 0.005) AllocationItem(e.key, e.value, total == 0 ? 0 : e.value / total),
  ]..sort((a, b) => b.value.compareTo(a.value));

  return PortfolioSnapshot(netWorth: total, pnl24h: pnl, items: items);
}
