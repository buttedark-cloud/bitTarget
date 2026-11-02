import 'dart:async';

import 'package:bittarget/features/trade/data/trade_models.dart';
import 'package:bittarget/features/trade/data/trade_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum TradeStatus { loading, ready, error }

// Состояние живого соединения (WebSocket)
enum LiveStatus { connecting, live, reconnecting }

class TradeState {
  final TradeStatus status;
  final String symbol;
  final String interval;
  final List<Candle> candles;
  final TickerData? ticker;
  final OrderBook? orderBook;
  final Set<String> favorites;
  final bool showMa;
  final bool showDots;
  final String? error; // текст ошибки, когда данных нет совсем
  final LiveStatus live;
  final bool chartError; // график не обновился, но старые данные ещё на экране
  final bool bookFailed; // стакан недоступен

  const TradeState({
    this.status = TradeStatus.loading,
    this.symbol = 'BTC',
    this.interval = '15m',
    this.candles = const [],
    this.ticker,
    this.orderBook,
    this.favorites = const {},
    this.showMa = false,
    this.showDots = true,
    this.error,
    this.live = LiveStatus.connecting,
    this.chartError = false,
    this.bookFailed = false,
  });

  TradeState copyWith({
    TradeStatus? status,
    String? symbol,
    String? interval,
    List<Candle>? candles,
    TickerData? ticker,
    OrderBook? orderBook,
    Set<String>? favorites,
    bool? showMa,
    bool? showDots,
    String? error,
    bool clearError = false,
    LiveStatus? live,
    bool? chartError,
    bool? bookFailed,
  }) {
    return TradeState(
      status: status ?? this.status,
      symbol: symbol ?? this.symbol,
      interval: interval ?? this.interval,
      candles: candles ?? this.candles,
      ticker: ticker ?? this.ticker,
      orderBook: orderBook ?? this.orderBook,
      favorites: favorites ?? this.favorites,
      showMa: showMa ?? this.showMa,
      showDots: showDots ?? this.showDots,
      error: clearError ? null : (error ?? this.error),
      live: live ?? this.live,
      chartError: chartError ?? this.chartError,
      bookFailed: bookFailed ?? this.bookFailed,
    );
  }
}

class TradeCubit extends Cubit<TradeState> {
  static const int candleLimit = 48;
  static const Duration _requestTimeout = Duration(seconds: 15);

  final TradeService _service;

  StreamSubscription<TickerData>? _tickerSub;
  StreamSubscription<Candle>? _klineSub;
  StreamSubscription<OrderBook>? _depthSub;
  Timer? _reconnectTimer;
  Timer? _bookTimer;

  // Видна ли вкладка торговли. Пока не видна, сокеты закрыты
  bool _active;

  // Когда последний раз стакан пришёл по сокету, и для какой монеты сейчас идёт запасной запрос
  DateTime _lastBookAt = DateTime.fromMillisecondsSinceEpoch(0);
  String? _bookFetchingSym;

  // ignore: prefer_initializing_formals
  TradeCubit(this._service, {String symbol = 'BTC', bool active = true}) : _active = active, super(TradeState(symbol: symbol));

  String get symbol => state.symbol;
  String get pair => '${state.symbol}/USDT';

  Future<void> load({String? interval}) async {
    final sym = state.symbol;
    final prevInterval = state.interval;
    final tf = interval ?? prevInterval;
    // Если данные уже есть на экране, при сбое покажем их дальше
    final hadData = state.ticker != null && state.candles.isNotEmpty;

    _stopStreams();
    emit(state.copyWith(status: TradeStatus.loading, interval: tf, clearError: true, chartError: false));

    var step = 'candles';
    try {
      // Шаги идут по очереди, чтобы в ошибке было видно, на каком именно всё сломалось
      final candles = await _service.fetchCandles(sym, tf, limit: candleLimit).timeout(_requestTimeout);
      step = 'ticker';
      final ticker = await _service.fetchTicker(sym).timeout(_requestTimeout);

      // Если за это время закрыли экран или выбрали другую монету или таймфрейм, ответ устарел
      if (isClosed || state.symbol != sym || state.interval != tf) return;

      emit(state.copyWith(status: TradeStatus.ready, candles: candles, ticker: ticker, clearError: true));
      if (_active) _startStreams();
    } catch (e, st) {
      debugPrint('TradeCubit.load failed at $step: $e\n$st');
      if (isClosed || state.symbol != sym || state.interval != tf) return;

      if (hadData) {
        // Возвращаем прежний таймфрейм: старые свечи принадлежат ему
        emit(state.copyWith(status: TradeStatus.ready, interval: prevInterval, chartError: true));
        if (_active) _startStreams();
      } else {
        var text = '$step: $e';
        if (text.length > 300) text = text.substring(0, 300);
        emit(state.copyWith(status: TradeStatus.error, error: text));
      }
    }
  }

  // Вкладка ушла на задний план: закрываем сокеты. Вернулись: данные устарели, грузим заново
  void setActive(bool active) {
    if (active == _active) return;
    _active = active;

    if (!active) {
      _stopStreams();
    } else if (state.ticker != null || state.status == TradeStatus.error) {
      load();
    }
  }

  void selectInterval(String tf) {
    if (tf != state.interval) load(interval: tf);
  }

  // Смена монеты: сбрасываем старые данные, чтобы не показывать цены прошлой монеты
  void selectSymbol(String newSymbol) {
    if (newSymbol == state.symbol) return;
    _stopStreams();
    emit(
      TradeState(symbol: newSymbol, interval: state.interval, favorites: state.favorites, showMa: state.showMa, showDots: state.showDots),
    );
    load();
  }

  void toggleFavorite(String symbol) {
    final next = {...state.favorites};
    if (!next.remove(symbol)) next.add(symbol);
    emit(state.copyWith(favorites: next));
  }

  void toggleMa() => emit(state.copyWith(showMa: !state.showMa));

  void toggleDots() => emit(state.copyWith(showDots: !state.showDots));

  // Кнопка «Повторить» под стаканом
  void retryBook() {
    emit(state.copyWith(bookFailed: false));
    _fetchBookSnapshot();
  }

  void _startStreams({bool reconnect = false}) {
    _stopStreams();
    // При переподключении остаёмся в состоянии «переподключение» до первого сообщения
    if (!reconnect) emit(state.copyWith(live: LiveStatus.connecting));

    _tickerSub = _service
        .tickerStream(state.symbol)
        .listen(
          (t) => emit(state.copyWith(ticker: t, live: LiveStatus.live)),
          onError: (_) => _onStreamLost(),
          onDone: _onStreamLost,
        );
    _klineSub = _service.klineStream(state.symbol, state.interval).listen(_onKline, onError: (_) => _onStreamLost(), onDone: _onStreamLost);
    _depthSub = _service
        .depthStream(state.symbol)
        .listen(
          (b) {
            _lastBookAt = DateTime.now();
            emit(state.copyWith(orderBook: b, bookFailed: false, live: LiveStatus.live));
          },
          onError: (_) => _onStreamLost(),
          onDone: _onStreamLost,
        );

    // Стакан показываем сразу обычным запросом, не дожидаясь сокета
    _lastBookAt = DateTime.fromMillisecondsSinceEpoch(0);
    _fetchBookSnapshot();

    // Если сокет со стаканом молчит больше 4 секунд, обновляем стакан обычными запросами
    _bookTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (isClosed || !_active) return;
      if (DateTime.now().difference(_lastBookAt) > const Duration(seconds: 4)) _fetchBookSnapshot();
    });
  }

  void _stopStreams() {
    _reconnectTimer?.cancel();
    _bookTimer?.cancel();
    _tickerSub?.cancel();
    _klineSub?.cancel();
    _depthSub?.cancel();
    _tickerSub = null;
    _klineSub = null;
    _depthSub = null;
    _bookTimer = null;
  }

  Future<void> _fetchBookSnapshot() async {
    final sym = state.symbol;
    if (_bookFetchingSym == sym) return; // такой запрос уже идёт
    _bookFetchingSym = sym;

    try {
      final book = await _service.fetchOrderBook(sym).timeout(_requestTimeout);
      if (isClosed || state.symbol != sym) return;
      emit(state.copyWith(orderBook: book, bookFailed: false));
    } catch (e) {
      debugPrint('Order book request failed: $e');
      if (!isClosed && state.symbol == sym && state.orderBook == null) emit(state.copyWith(bookFailed: true));
    } finally {
      if (_bookFetchingSym == sym) _bookFetchingSym = null;
    }
  }

  // Связь оборвалась: сообщаем об этом экрану и пробуем подключиться снова
  void _onStreamLost() {
    if (isClosed) return;
    if (state.live != LiveStatus.reconnecting) emit(state.copyWith(live: LiveStatus.reconnecting));
    _scheduleReconnect();
  }

  // Подключаемся снова через 3 секунды (только если вкладка активна)
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (!isClosed && _active) _startStreams(reconnect: true);
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
    emit(state.copyWith(candles: list, live: LiveStatus.live));
  }

  @override
  Future<void> close() {
    _stopStreams();
    return super.close();
  }
}
