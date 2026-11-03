import 'dart:convert';

import 'package:bittarget/core/network/api_client.dart';
import 'package:bittarget/features/home/data/crypto_asset_model.dart';
import 'package:flutter/foundation.dart';

class CryptoApiService {
  final ApiClient _api = ApiClient.shared;

  static const List<String> targetSymbols = [
    'BTCUSDT',
    'ETHUSDT',
    'SOLUSDT',
    'TONUSDT', // если пара GRAMUSDT живая, замени на 'GRAMUSDT'
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
    'GRAM': 'Грам',
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

  // Если по монете не было сделок дольше этого времени, считаем, что пара не торгуется
  static const Duration _maxStale = Duration(hours: 12);

  // Цены, изменение и максимум за 24 часа: все монеты одним запросом
  Future<List<CryptoAsset>> fetchMarketData() async {
    final List data = await _api.get<List<dynamic>>(
      'https://api.binance.com/api/v3/ticker/24hr',
      queryParameters: {'symbols': jsonEncode(targetSymbols)},
    );
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    final fresh = data.where((item) {
      final closeTime = (item['closeTime'] as num?)?.toInt() ?? 0;
      final stale = nowMs - closeTime > _maxStale.inMilliseconds;
      if (stale) {
        debugPrint('Пропускаем ${item['symbol']}: нет сделок с ${DateTime.fromMillisecondsSinceEpoch(closeTime)}');
      }
      return !stale;
    }).toList();

    // Если отфильтровалось всё (например, неверные часы на устройстве), показываем как есть
    final source = fresh.isEmpty ? data : fresh;

    return source.map((item) {
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
    final List data = await _api.get<List<dynamic>>(
      'https://api.binance.com/api/v3/klines',
      queryParameters: {'symbol': '${symbol}USDT', 'interval': '1h', 'limit': 24},
    );

    return data.map<double>((candle) => double.parse(candle[4])).toList();
  }
}
