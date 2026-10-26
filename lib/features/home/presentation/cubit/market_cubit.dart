import 'dart:async';

import 'package:bittarget/features/home/data/crypto_api_service.dart';
import 'package:bittarget/features/home/data/crypto_asset_model.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MarketState {}

class MarketLoading extends MarketState {}

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
    final assets = await _apiService.fetchMarketData();
    if (assets.isNotEmpty) {
      // По умолчанию выбираем BTC для главного графика
      final btc = assets.firstWhere((element) => element.symbol == 'BTC', orElse: () => assets.first);
      emit(MarketLoaded(assets: assets, selectedAsset: btc));
    }

    // Периодический опрос бэкенда для обновления цен в реальном времени
    _timer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final updatedAssets = await _apiService.fetchMarketData();
      if (updatedAssets.isNotEmpty && state is MarketLoaded) {
        final currentSelected = (state as MarketLoaded).selectedAsset;
        final newSelected = updatedAssets.firstWhere(
          (element) => element.symbol == currentSelected.symbol,
          orElse: () => updatedAssets.first,
        );
        emit(MarketLoaded(assets: updatedAssets, selectedAsset: newSelected));
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
