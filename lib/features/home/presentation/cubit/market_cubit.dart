import 'dart:async';

import 'package:bittarget/core/network/api_client.dart';
import 'package:bittarget/features/home/data/crypto_api_service.dart';
import 'package:bittarget/features/home/data/crypto_asset_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MarketState {}

class MarketLoading extends MarketState {}

class MarketError extends MarketState {
  final ApiErrorKind kind;

  MarketError(this.kind);
}

class MarketLoaded extends MarketState {
  final List<CryptoAsset> assets;
  final CryptoAsset selectedAsset;
  final bool offline; // связь потеряна, на экране последние известные цены

  MarketLoaded({required this.assets, required this.selectedAsset, this.offline = false});
}

class MarketCubit extends Cubit<MarketState> {
  final CryptoApiService _api;
  Timer? _timer;
  bool _polling = false;
  Map<String, List<double>> _charts = {};

  MarketCubit(this._api) : super(MarketLoading());

  Future<void> loadMarket() async {
    _timer?.cancel();
    emit(MarketLoading());
    try {
      final assets = await _api.fetchMarketData();
      if (assets.isEmpty) throw const ApiException(ApiErrorKind.unknown, 'empty market');
      await _loadCharts(assets);
      if (isClosed) return;

      final withCharts = _applyCharts(assets);
      final btc = withCharts.firstWhere((a) => a.symbol == 'BTC', orElse: () => withCharts.first);
      emit(MarketLoaded(assets: withCharts, selectedAsset: btc));
      _startPolling();
    } catch (e) {
      debugPrint('MarketCubit.loadMarket failed: $e');
      if (!isClosed) emit(MarketError(e is ApiException ? e.kind : ApiErrorKind.unknown));
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
      if (_polling) return; // предыдущий запрос ещё не закончился
      _polling = true;
      try {
        final updated = _applyCharts(await _api.fetchMarketData());
        final current = state;
        if (isClosed || current is! MarketLoaded || updated.isEmpty) return;

        final fresh = updated.firstWhere((a) => a.symbol == current.selectedAsset.symbol, orElse: () => updated.first);
        emit(MarketLoaded(assets: updated, selectedAsset: fresh));
      } catch (_) {
        // Связь пропала: оставляем последние цены и показываем полоску об этом
        final current = state;
        if (!isClosed && current is MarketLoaded && !current.offline) {
          emit(MarketLoaded(assets: current.assets, selectedAsset: current.selectedAsset, offline: true));
        }
      } finally {
        _polling = false;
      }
    });
  }

  void selectAsset(CryptoAsset asset) {
    final current = state;
    if (current is! MarketLoaded) return;
    emit(MarketLoaded(assets: current.assets, selectedAsset: asset, offline: current.offline));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
