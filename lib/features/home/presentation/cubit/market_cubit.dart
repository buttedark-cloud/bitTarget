import 'dart:async';

import 'package:bittarget/features/home/data/crypto_api_service.dart';
import 'package:bittarget/features/home/data/crypto_asset_model.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MarketState {}

class MarketLoading extends MarketState {}

class MarketError extends MarketState {}

class MarketLoaded extends MarketState {
  final List<CryptoAsset> assets;
  final CryptoAsset selectedAsset; // Выбранная монета для большого графика

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
      emit(MarketLoaded(assets: assets, selectedAsset: btc));
      _startPolling();
    } catch (_) {
      emit(MarketError());
    }
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final updated = await _apiService.fetchMarketData();
        if (isClosed || state is! MarketLoaded) return;

        final selected = (state as MarketLoaded).selectedAsset;
        final newSelected = updated.firstWhere((a) => a.symbol == selected.symbol, orElse: () => updated.first);
        emit(MarketLoaded(assets: updated, selectedAsset: newSelected));
      } catch (_) {
        // Сбой одного обновления не страшен: на экране остаются прошлые цены
      }
    });
  }

  void selectAsset(CryptoAsset asset) {
    if (state is MarketLoaded) {
      final currentState = state as MarketLoaded;
      emit(MarketLoaded(assets: currentState.assets, selectedAsset: asset));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
