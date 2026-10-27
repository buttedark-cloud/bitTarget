class CryptoAsset {
  final String symbol;
  final String nameRu;
  final String nameEn;
  final String pair;
  final double price;
  final double changePercent;
  final bool isPositive;
  final double high24h;
  final List<double> sparkline;

  const CryptoAsset({
    required this.symbol,
    required this.nameRu,
    required this.nameEn,
    required this.pair,
    required this.price,
    required this.changePercent,
    required this.isPositive,
    required this.high24h,
    required this.sparkline,
  });

  CryptoAsset copyWith({double? price, double? changePercent, bool? isPositive, double? high24h, List<double>? sparkline}) {
    return CryptoAsset(
      symbol: symbol,
      nameRu: nameRu,
      nameEn: nameEn,
      pair: pair,
      price: price ?? this.price,
      changePercent: changePercent ?? this.changePercent,
      isPositive: isPositive ?? this.isPositive,
      high24h: high24h ?? this.high24h,
      sparkline: sparkline ?? this.sparkline,
    );
  }
}
