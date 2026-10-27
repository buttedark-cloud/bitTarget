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

  static const Map<String, String> _ruNames = {
    'BTC': 'Биткоин',
    'ETH': 'Эфириум',
    'SOL': 'Солана',
    'TON': 'Тонкоин',
    'ADA': 'Кардано',
    'XRP': 'Рипл',
    'DOT': 'Полкадот',
    'DOGE': 'Догикоин',
    'AVAX': 'Аваланч',
    'LINK': 'Чейнлинк',
    'POL': 'Полигон',
    'UNI': 'Юнисвоп',
    'LTC': 'Лайткоин',
    'ATOM': 'Космос',
    'NEAR': 'Ниар',
  };

  // Цены, изменение и максимум за 24 часа: все монеты одним запросом
  Future<List<CryptoAsset>> fetchMarketData() async {
    final response = await _dio.get('https://api.binance.com/api/v3/ticker/24hr', queryParameters: {'symbols': jsonEncode(targetSymbols)});

    final List data = response.data;

    return data.map((item) {
      final symbol = item['symbol'].toString().replaceAll('USDT', '');
      final change = double.parse(item['priceChangePercent']);

      return CryptoAsset(
        symbol: symbol,
        nameRu: _ruNames[symbol] ?? symbol,
        nameEn: symbol,
        pair: '$symbol/USDT',
        price: double.parse(item['lastPrice']),
        changePercent: change.abs(),
        isPositive: change >= 0,
        high24h: double.parse(item['highPrice']),
        sparkline: const [],
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
    return data.map<double>((candle) => double.parse(candle[4])).toList();
  }
}
