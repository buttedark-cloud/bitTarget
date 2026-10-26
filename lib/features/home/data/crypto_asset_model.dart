class CryptoAsset {
  final String symbol;
  final String nameRu;
  final String nameEn;
  final String pair;
  double price;
  double changePercent;
  final bool isPositive;
  final String iconUrl;
  final List<double> sparkline; // Данные для графика

  CryptoAsset({
    required this.symbol,
    required this.nameRu,
    required this.nameEn,
    required this.pair,
    required this.price,
    required this.changePercent,
    required this.isPositive,
    required this.iconUrl,
    required this.sparkline,
  });

  CryptoAsset copyWith({double? price, double? changePercent, bool? isPositive, List<double>? sparkline}) {
    return CryptoAsset(
      symbol: symbol,
      nameRu: nameRu,
      nameEn: nameEn,
      pair: pair,
      price: price ?? this.price,
      changePercent: changePercent ?? this.changePercent,
      isPositive: isPositive ?? this.isPositive,
      iconUrl: iconUrl,
      sparkline: sparkline ?? this.sparkline,
    );
  }
}
