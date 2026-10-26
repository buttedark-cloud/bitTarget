import 'package:bittarget/features/home/data/crypto_asset_model.dart';

import 'package:dio/dio.dart';

class CryptoApiService {
  final Dio _dio = Dio();

  static const List<String> targetSymbols = [
    'BTCUSDT',
    'ETHUSDT',
    'SOLUSDT',
    'TONUSDT',
    'ADAUSDT',
    'XRPUSDT',
    'DOTUSDT',
    'DOGEUSDT',
    'AVAXUSDT',
    'LINKUSDT',
    'MATICUSDT',
    'UNIUSDT',
    'LTCUSDT',
    'ATOMUSDT',
    'NEARUSDT',
  ];

  Future<List<CryptoAsset>> fetchMarketData() async {
    try {
      final response = await _dio.get('https://api.binance.com/api/v3/ticker/24hr');
      if (response.statusCode == 200) {
        final List data = response.data;

        return data.where((item) => targetSymbols.contains(item['symbol'])).map((item) {
          final price = double.parse(item['lastPrice']);
          final change = double.parse(item['priceChangePercent']);
          final rawSymbol = item['symbol'].toString().replaceAll('USDT', '').toLowerCase();
          final upperSymbol = item['symbol'].toString().replaceAll('USDT', '');

          // Официальные иконки крипты из открытых источников с привязкой к сайтам
          final iconUrl = 'https://assets.coincap.io/assets/icons/$rawSymbol@2x.png';

          // Генерируем фейковый массив для графика на основе изменения цены
          List<double> mockSparkline = List.generate(20, (index) => price * (1 + (index - 10) * 0.001 * (change >= 0 ? 1 : -1)));

          return CryptoAsset(
            symbol: upperSymbol,
            nameRu: _getRussianName(upperSymbol),
            nameEn: upperSymbol,
            pair: '$upperSymbol/USDT',
            price: price,
            changePercent: change.abs(),
            isPositive: change >= 0,
            iconUrl: iconUrl,
            sparkline: mockSparkline,
          );
        }).toList();
      }
    } catch (e) {
      print('Ошибка загрузки с Binance: $e');
    }
    return [];
  }

  String _getRussianName(String symbol) {
    switch (symbol) {
      case 'BTC':
        return 'Биткоин';
      case 'ETH':
        return 'Эфириум';
      case 'SOL':
        return 'Солана';
      case 'TON':
        return 'Тонкоин';
      case 'ADA':
        return 'Кардано';
      case 'XRP':
        return 'Рипл';
      case 'DOT':
        return 'Полкадот';
      case 'DOGE':
        return 'Догикоин';
      case 'AVAX':
        return 'Аваланч';
      case 'LINK':
        return 'Чейнлинк';
      case 'MATIC':
        return 'Полигин';
      case 'UNI':
        return 'Юнивос';
      case 'LTC':
        return 'Лайткоин';
      case 'ATOM':
        return 'Космос';
      case 'NEAR':
        return 'Нир';
      default:
        return symbol;
    }
  }
}
