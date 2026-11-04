import 'package:bittarget/core/network/api_client.dart';
import 'package:bittarget/features/home/data/crypto_api_service.dart';
import 'package:bittarget/features/home/data/crypto_asset_model.dart';
import 'package:bittarget/features/home/presentation/cubit/market_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

CryptoAsset asset(String symbol, double price) {
  return CryptoAsset(
    symbol: symbol,
    nameRu: symbol,
    nameEn: symbol,
    pair: '$symbol/USDT',
    price: price,
    changePercent: 1,
    isPositive: true,
    high24h: price,
    sparkline: const [],
  );
}

class FakeApi extends CryptoApiService {
  bool fail = false;
  bool empty = false;

  @override
  Future<List<CryptoAsset>> fetchMarketData() async {
    if (fail) throw const ApiException(ApiErrorKind.timeout);
    if (empty) return [];
    return [asset('ETH', 3000), asset('BTC', 60000)];
  }

  @override
  Future<List<double>> fetchSparkline(String symbol) async => [1, 2, 3];
}

void main() {
  group('MarketCubit', () {
    late FakeApi api;
    late MarketCubit cubit;

    setUp(() {
      api = FakeApi();
      cubit = MarketCubit(api);
    });
    tearDown(() => cubit.close());

    test('загрузка: BTC выбран по умолчанию, графики подставлены', () async {
      await cubit.loadMarket();

      final state = cubit.state as MarketLoaded;
      expect(state.assets.length, 2);
      expect(state.selectedAsset.symbol, 'BTC');
      expect(state.selectedAsset.sparkline.length, 3);
      expect(state.selectedAsset.sparkline.last, 60000); // последняя точка = текущая цена
      expect(state.offline, isFalse);
    });

    test('ошибка загрузки: состояние «ошибка» с причиной', () async {
      api.fail = true;
      await cubit.loadMarket();

      final state = cubit.state;
      expect(state, isA<MarketError>());
      expect((state as MarketError).kind, ApiErrorKind.timeout);
    });

    test('пустой ответ рынка считается ошибкой, а не вечной загрузкой', () async {
      api.empty = true;
      await cubit.loadMarket();

      expect(cubit.state, isA<MarketError>());
    });

    test('«Повторить» после ошибки загружает рынок', () async {
      api.fail = true;
      await cubit.loadMarket();
      expect(cubit.state, isA<MarketError>());

      api.fail = false;
      await cubit.loadMarket();
      expect(cubit.state, isA<MarketLoaded>());
    });

    test('выбор другой монеты', () async {
      await cubit.loadMarket();
      final eth = (cubit.state as MarketLoaded).assets.firstWhere((a) => a.symbol == 'ETH');

      cubit.selectAsset(eth);
      expect((cubit.state as MarketLoaded).selectedAsset.symbol, 'ETH');
    });
  });
}
