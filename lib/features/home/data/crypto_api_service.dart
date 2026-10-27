import 'dart:convert';

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
    'POLUSDT',
    'UNIUSDT',
    'LTCUSDT',
    'ATOMUSDT',
    'NEARUSDT',
  ];

  // Цены и изменение за 24 часа для всех монет одним запросом
  Future<List<CryptoAsset>> fetchMarketData() async {
    final response = await _dio.get('https://api.binance.com/api/v3/ticker/24hr', queryParameters: {'symbols': jsonEncode(targetSymbols)});

    final List data = response.data;

    return data.map((item) {
      final price = double.parse(item['lastPrice']);
      final change = double.parse(item['priceChangePercent']);
      final upperSymbol = item['symbol'].toString().replaceAll('USDT', '');
      final rawSymbol = upperSymbol.toLowerCase();

      final iconUrl = 'https://assets.coincap.io/assets/icons/$rawSymbol@2x.png';

      return CryptoAsset(
        symbol: upperSymbol,
        nameRu: _getRussianName(upperSymbol),
        nameEn: upperSymbol,
        pair: '$upperSymbol/USDT',
        price: price,
        changePercent: change.abs(),
        isPositive: change >= 0,
        iconUrl: iconUrl,
        sparkline: const [], // график грузится отдельно, только для выбранной монеты
      );
    }).toList();
  }

  // Настоящий график: цены закрытия 24 часовых свечей
  Future<List<double>> fetchSparkline(String symbol) async {
    final response = await _dio.get(
      'https://api.binance.com/api/v3/klines',
      queryParameters: {'symbol': '${symbol}USDT', 'interval': '1h', 'limit': 24},
    );

    final List data = response.data;

    // В каждой свече индекс 4 — цена закрытия
    return data.map<double>((candle) => double.parse(candle[4])).toList();
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
      case 'POL':
        return 'Полигон';
      case 'UNI':
        return 'Юнисвоп';
      case 'LTC':
        return 'Лайткоин';
      case 'ATOM':
        return 'Космос';
      case 'NEAR':
        return 'Ниар';
      default:
        return symbol;
    }
  }
}
