import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class BinanceWsService {
  // Публичный WebSocket поток Binance для минутных свечей BTCUSDT в реальном времени
  final String _url = 'wss://stream.binance.com:9443/ws/btcusdt@kline_1m';

  WebSocketChannel? _channel;

  // Поток данных для прослушивания на экране Trade
  Stream<Map<String, dynamic>> get priceStream {
    _channel = WebSocketChannel.connect(Uri.parse(_url));

    return _channel!.stream.map((event) {
      final data = jsonDecode(event);
      final kline = data['k'];

      return {
        'price': double.parse(kline['c']), // Текущая цена закрытия
        'high': double.parse(kline['h']), // Максимум за период
        'low': double.parse(kline['l']), // Минимум за период
        'isClosed': kline['x'], // Закрыта ли свеча
      };
    });
  }

  // Закрытие соединения при выходе с экрана
  void dispose() {
    _channel?.sink.close();
  }
}
