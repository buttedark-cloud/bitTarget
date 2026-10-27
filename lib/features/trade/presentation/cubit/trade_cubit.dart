import 'dart:async';

import 'package:bittarget/features/trade/data/trade_models.dart';
import 'package:bittarget/features/trade/data/trade_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum TradeStatus { loading, ready, error }

class TradeState {
  final TradeStatus status;
  final String interval;
  final List<Candle> candles;
  final TickerData? ticker;
  final OrderBook? orderBook;

  const TradeState({this.status = TradeStatus.loading, this.interval = '15m', this.candles = const [], this.ticker, this.orderBook});

  TradeState copyWith({TradeStatus? status, String? interval, List<Candle>? candles, TickerData? ticker, OrderBook? orderBook}) {
    return TradeState(
      status: status ?? this.status,
      interval: interval ?? this.interval,
      candles: candles ?? this.candles,
      ticker: ticker ?? this.ticker,
      orderBook: orderBook ?? this.orderBook,
    );
  }
}

class TradeCubit extends Cubit<TradeState> {
  static const int candleLimit = 48;

  final TradeService _service;
  final String symbol;

  StreamSubscription<TickerData>? _tickerSub;
  StreamSubscription<Candle>? _klineSub;
  StreamSubscription<OrderBook>? _depthSub;
  Timer? _reconnectTimer;

  TradeCubit(this._service, {this.symbol = 'BTC'}) : super(const TradeState());

  String get pair => '$symbol/USDT';

  Future<void> load({String? interval}) async {
    final tf = interval ?? state.interval;
    _stopStreams();
    emit(state.copyWith(status: TradeStatus.loading, interval: tf));

    try {
      final (candles, ticker) = await (_service.fetchCandles(symbol, tf, limit: candleLimit), _service.fetchTicker(symbol)).wait;

      // Если за это время закрыли экран или выбрали другой таймфрейм, ответ устарел
      if (isClosed || state.interval != tf) return;

      emit(state.copyWith(status: TradeStatus.ready, candles: candles, ticker: ticker));
      _startStreams();
    } catch (_) {
      if (!isClosed && state.interval == tf) emit(state.copyWith(status: TradeStatus.error));
    }
  }

  void selectInterval(String tf) {
    if (tf != state.interval) load(interval: tf);
  }

  void _startStreams() {
    _stopStreams();
    _tickerSub = _service
        .tickerStream(symbol)
        .listen(
          (t) => emit(state.copyWith(ticker: t)),
          onError: (_) => _scheduleReconnect(),
          onDone: _scheduleReconnect,
        );
    _klineSub = _service
        .klineStream(symbol, state.interval)
        .listen(_onKline, onError: (_) => _scheduleReconnect(), onDone: _scheduleReconnect);
    _depthSub = _service
        .depthStream(symbol)
        .listen(
          (b) => emit(state.copyWith(orderBook: b)),
          onError: (_) => _scheduleReconnect(),
          onDone: _scheduleReconnect,
        );
  }

  void _stopStreams() {
    _reconnectTimer?.cancel();
    _tickerSub?.cancel();
    _klineSub?.cancel();
    _depthSub?.cancel();
    _tickerSub = null;
    _klineSub = null;
    _depthSub = null;
  }

  // Связь оборвалась: через 3 секунды пробуем подключиться снова
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (!isClosed) _startStreams();
    });
  }

  // Обновляем последнюю свечу или добавляем новую, когда началась следующая
  void _onKline(Candle c) {
    if (state.candles.isEmpty) return;
    final list = [...state.candles];

    if (list.last.time == c.time) {
      list[list.length - 1] = c;
    } else if (c.time.isAfter(list.last.time)) {
      list.add(c);
      if (list.length > candleLimit) list.removeAt(0);
    }
    emit(state.copyWith(candles: list));
  }

  @override
  Future<void> close() {
    _stopStreams();
    return super.close();
  }
}
