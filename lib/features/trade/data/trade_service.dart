import 'dart:async';
import 'dart:convert';

import 'package:bittarget/features/trade/data/trade_models.dart';
import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class TradeService {
  final Dio _dio = Dio();

  static const _rest = 'https://api.binance.com/api/v3';
  static const _ws = 'wss://stream.binance.com:9443/ws';

  // История для графика: цены закрытия свечей
  Future<List<Candle>> fetchCandles(String symbol, String interval, {int limit = 48}) async {
    final response = await _dio.get('$_rest/klines', queryParameters: {'symbol': '${symbol}USDT', 'interval': interval, 'limit': limit});
    final List data = response.data;
    return data.map<Candle>((c) => Candle(DateTime.fromMillisecondsSinceEpoch(c[0] as int), double.parse(c[4]))).toList();
  }

  // Цена, изменение, максимум и минимум за 24 часа
  Future<TickerData> fetchTicker(String symbol) async {
    final response = await _dio.get('$_rest/ticker/24hr', queryParameters: {'symbol': '${symbol}USDT'});
    final d = response.data;
    return TickerData(
      price: double.parse(d['lastPrice']),
      change: double.parse(d['priceChange']),
      changePercent: double.parse(d['priceChangePercent']),
      high: double.parse(d['highPrice']),
      low: double.parse(d['lowPrice']),
    );
  }

  // Живая цена (обновляется примерно раз в секунду)
  Stream<TickerData> tickerStream(String symbol) {
    return _stream('$_ws/${symbol.toLowerCase()}usdt@ticker', (d) {
      return TickerData(
        price: double.parse(d['c']),
        change: double.parse(d['p']),
        changePercent: double.parse(d['P']),
        high: double.parse(d['h']),
        low: double.parse(d['l']),
      );
    });
  }

  // Живая последняя свеча
  Stream<Candle> klineStream(String symbol, String interval) {
    return _stream('$_ws/${symbol.toLowerCase()}usdt@kline_$interval', (d) {
      final k = d['k'];
      return Candle(DateTime.fromMillisecondsSinceEpoch(k['t'] as int), double.parse(k['c']));
    });
  }

  // Живой стакан: 5 лучших уровней покупки и продажи раз в секунду
  Stream<OrderBook> depthStream(String symbol) {
    return _stream('$_ws/${symbol.toLowerCase()}usdt@depth5@1000ms', (d) {
      List<OrderBookLevel> parse(List raw) {
        return raw.map<OrderBookLevel>((l) => OrderBookLevel(double.parse(l[0]), double.parse(l[1]))).toList();
      }

      return OrderBook(bids: parse(d['bids']), asks: parse(d['asks']));
    });
  }

  // Общая обёртка: открывает сокет, когда на поток подписываются,
  // и закрывает его, когда отписываются
  Stream<T> _stream<T>(String url, T Function(Map<String, dynamic>) parse) {
    late final StreamController<T> controller;
    WebSocketChannel? channel;
    StreamSubscription? sub;

    controller = StreamController<T>(
      onListen: () {
        channel = WebSocketChannel.connect(Uri.parse(url));
        sub = channel!.stream.listen(
          (raw) {
            try {
              controller.add(parse(jsonDecode(raw as String) as Map<String, dynamic>));
            } catch (_) {
              // Служебное сообщение другого формата: пропускаем
            }
          },
          onError: controller.addError,
          onDone: controller.close,
        );
      },
      onCancel: () async {
        await sub?.cancel();
        await channel?.sink.close();
      },
    );

    return controller.stream;
  }
}
