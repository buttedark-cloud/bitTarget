import 'dart:async';

import 'package:bittarget/features/home/data/crypto_api_service.dart';
import 'package:bittarget/features/home/data/crypto_asset_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MarketState {}

class MarketLoading extends MarketState {}

class MarketError extends MarketState {}

class MarketLoaded extends MarketState {
  final List<CryptoAsset> assets;
  final CryptoAsset selectedAsset; // монета для большого графика

  MarketLoaded({required this.assets, required this.selectedAsset});
}

class MarketCubit extends Cubit<MarketState> {
  final CryptoApiService _apiService;
  Timer? _timer;

  MarketCubit(this._apiService) : super(MarketLoading());

  Future<void> loadMarket() async {
    emit(MarketLoading());
    try {
      final assets = await _apiService.fetchMarketData();
      final btc = assets.firstWhere((a) => a.symbol == 'BTC', orElse: () => assets.first);
      final chart = await _loadChart(btc.symbol);

      if (isClosed) return;
      emit(
        MarketLoaded(
          assets: assets,
          selectedAsset: btc.copyWith(sparkline: chart),
        ),
      );
      _startPolling();
    } catch (_) {
      if (!isClosed) emit(MarketError());
    }
  }

  // Если график не загрузился, это не повод ломать весь экран: вернём пустой список
  Future<List<double>> _loadChart(String symbol) async {
    try {
      return await _apiService.fetchSparkline(symbol);
    } catch (_) {
      return [];
    }
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final updated = await _apiService.fetchMarketData();
        if (isClosed || state is! MarketLoaded) return;

        final selected = (state as MarketLoaded).selectedAsset;
        final fresh = updated.firstWhere((a) => a.symbol == selected.symbol, orElse: () => updated.first);

        // Оставляем загруженный график, но последнюю точку двигаем к текущей цене
        var chart = selected.sparkline;
        if (chart.isNotEmpty) {
          chart = [...chart.sublist(0, chart.length - 1), fresh.price];
        }

        emit(
          MarketLoaded(
            assets: updated,
            selectedAsset: fresh.copyWith(sparkline: chart),
          ),
        );
      } catch (_) {
        // Сбой одного обновления не страшен: на экране остаются прошлые цены
      }
    });
  }

  Future<void> selectAsset(CryptoAsset asset) async {
    final current = state;
    if (current is! MarketLoaded) return;

    // Сразу показываем выбранную монету, график подгрузится следом
    emit(MarketLoaded(assets: current.assets, selectedAsset: asset));

    final chart = await _loadChart(asset.symbol);

    final now = state;
    if (isClosed || now is! MarketLoaded || now.selectedAsset.symbol != asset.symbol) return;
    emit(
      MarketLoaded(
        assets: now.assets,
        selectedAsset: now.selectedAsset.copyWith(sparkline: chart),
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
