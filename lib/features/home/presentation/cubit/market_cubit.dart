import 'dart:async';

import 'package:bittarget/features/home/data/crypto_api_service.dart';
import 'package:bittarget/features/home/data/crypto_asset_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MarketState {}

class MarketLoading extends MarketState {}

class MarketError extends MarketState {}

class MarketLoaded extends MarketState {
  final List<CryptoAsset> assets;
  final CryptoAsset selectedAsset;

  MarketLoaded({required this.assets, required this.selectedAsset});
}

class MarketCubit extends Cubit<MarketState> {
  final CryptoApiService _api;
  Timer? _timer;
  Map<String, List<double>> _charts = {};

  MarketCubit(this._api) : super(MarketLoading());

  Future<void> loadMarket() async {
    emit(MarketLoading());
    try {
      final assets = await _api.fetchMarketData();
      await _loadCharts(assets);
      if (isClosed) return;

      final withCharts = _applyCharts(assets);
      final btc = withCharts.firstWhere((a) => a.symbol == 'BTC', orElse: () => withCharts.first);
      emit(MarketLoaded(assets: withCharts, selectedAsset: btc));
      _startPolling();
    } catch (_) {
      if (!isClosed) emit(MarketError());
    }
  }

  // Если график одной монеты не загрузился, остальное продолжает работать
  Future<MapEntry<String, List<double>>> _chartFor(String symbol) async {
    try {
      return MapEntry(symbol, await _api.fetchSparkline(symbol));
    } catch (_) {
      return MapEntry(symbol, <double>[]);
    }
  }

  Future<void> _loadCharts(List<CryptoAsset> assets) async {
    final results = await Future.wait(assets.map((a) => _chartFor(a.symbol)));
    _charts = Map.fromEntries(results);
  }

  // Подставляем графики и двигаем последнюю точку к текущей цене
  List<CryptoAsset> _applyCharts(List<CryptoAsset> assets) {
    return assets.map((a) {
      final chart = _charts[a.symbol] ?? const <double>[];
      if (chart.isEmpty) return a;
      return a.copyWith(sparkline: [...chart.sublist(0, chart.length - 1), a.price]);
    }).toList();
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final updated = _applyCharts(await _api.fetchMarketData());
        if (isClosed || state is! MarketLoaded) return;

        final selected = (state as MarketLoaded).selectedAsset;
        final fresh = updated.firstWhere((a) => a.symbol == selected.symbol, orElse: () => updated.first);
        emit(MarketLoaded(assets: updated, selectedAsset: fresh));
      } catch (_) {
        // Сбой одного обновления не страшен: остаются прошлые цены
      }
    });
  }

  void selectAsset(CryptoAsset asset) {
    final current = state;
    if (current is! MarketLoaded) return;
    emit(MarketLoaded(assets: current.assets, selectedAsset: asset));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
