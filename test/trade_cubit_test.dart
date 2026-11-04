import 'package:bittarget/core/network/api_client.dart';
import 'package:bittarget/features/trade/data/trade_models.dart';
import 'package:bittarget/features/trade/data/trade_service.dart';
import 'package:bittarget/features/trade/presentation/cubit/trade_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

// «Подделка» вместо настоящего Binance: данные приходят мгновенно, сеть не нужна
class FakeTradeService extends TradeService {
  bool failTicker = false;
  final List<String> requestedSymbols = [];

  @override
  Future<List<Candle>> fetchCandles(String symbol, String interval, {int limit = 48}) async {
    requestedSymbols.add(symbol);
    return List.generate(limit, (i) => Candle(DateTime(2026, 1, 1).add(Duration(minutes: 15 * i)), 100.0 + i));
  }

  @override
  Future<TickerData> fetchTicker(String symbol) async {
    if (failTicker) throw const ApiException(ApiErrorKind.network);
    return const TickerData(price: 123, change: 1, changePercent: 1, high: 130, low: 110);
  }

  @override
  Future<OrderBook> fetchOrderBook(String symbol) async => const OrderBook(bids: [], asks: []);

  @override
  Stream<TickerData> tickerStream(String symbol) => const Stream<TickerData>.empty();

  @override
  Stream<Candle> klineStream(String symbol, String interval) => const Stream<Candle>.empty();

  @override
  Stream<OrderBook> depthStream(String symbol) => const Stream<OrderBook>.empty();
}

void main() {
  group('TradeCubit', () {
    late FakeTradeService service;
    late TradeCubit cubit;

    // active: false: не открываем сокеты в тестах
    setUp(() {
      service = FakeTradeService();
      cubit = TradeCubit(service, active: false);
    });
    tearDown(() => cubit.close());

    test('успешная загрузка', () async {
      await cubit.load();

      expect(cubit.state.status, TradeStatus.ready);
      expect(cubit.state.candles.length, 48);
      expect(cubit.state.ticker?.price, 123);
    });

    test('ошибка без данных: состояние «ошибка» и понятная причина', () async {
      service.failTicker = true;
      await cubit.load();

      expect(cubit.state.status, TradeStatus.error);
      expect(cubit.state.errorKind, ApiErrorKind.network);
      expect(cubit.state.ticker, isNull);
    });

    test('ошибка при смене таймфрейма: старый график остаётся, таймфрейм откатывается', () async {
      await cubit.load();
      service.failTicker = true;
      await cubit.load(interval: '1h');

      expect(cubit.state.status, TradeStatus.ready);
      expect(cubit.state.chartError, isTrue);
      expect(cubit.state.interval, '15m');
      expect(cubit.state.candles.length, 48);
    });

    test('после ошибки «Повторить» загружает данные', () async {
      service.failTicker = true;
      await cubit.load();
      expect(cubit.state.status, TradeStatus.error);

      service.failTicker = false;
      await cubit.load();
      expect(cubit.state.status, TradeStatus.ready);
      expect(cubit.state.errorKind, isNull);
    });

    test('смена монеты сбрасывает старые данные и грузит новые', () async {
      await cubit.load();

      cubit.selectSymbol('ETH');
      expect(cubit.state.symbol, 'ETH');
      expect(cubit.state.ticker, isNull); // цены BTC не показываем под видом ETH

      await cubit.stream.firstWhere((s) => s.status == TradeStatus.ready).timeout(const Duration(seconds: 2));
      expect(cubit.state.ticker, isNotNull);
      expect(service.requestedSymbols.last, 'ETH');
    });

    test('избранное и настройки графика переключаются', () {
      cubit.toggleFavorite('BTC');
      expect(cubit.state.favorites, {'BTC'});
      cubit.toggleFavorite('BTC');
      expect(cubit.state.favorites, isEmpty);

      expect(cubit.state.showMa, isFalse);
      cubit.toggleMa();
      expect(cubit.state.showMa, isTrue);
    });
  });
}
