import 'dart:math' as math;

import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/core/utils/decimal_input_formatter.dart';
import 'package:bittarget/core/utils/format.dart';
import 'package:bittarget/core/widgets/coin_icon.dart';
import 'package:bittarget/core/widgets/press_effect.dart';
import 'package:bittarget/features/home/data/crypto_asset_model.dart';
import 'package:bittarget/features/home/presentation/cubit/market_cubit.dart';
import 'package:bittarget/features/wallet/cubit/wallet_cubit.dart';
import 'package:bittarget/features/wallet/portfolio.dart';
import 'package:bittarget/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

enum WalletAction { deposit, withdraw, convert, transfer }

const double kNetworkFeeUsd = 1.0;

void showWalletActionSheet(BuildContext context, WalletAction action) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF121214),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (sheetContext) => Padding(
      // Поднимаем панель над клавиатурой
      padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
      child: _WalletActionSheet(action: action),
    ),
  );
}

String _trim(double v) => v.toStringAsFixed(6).replaceFirst(RegExp(r'\.?0+$'), '');

double _floorTo(double v, int decimals) {
  final f = math.pow(10, decimals).toDouble();
  return (v * f + 1e-9).floor() / f;
}

class _WalletActionSheet extends StatefulWidget {
  final WalletAction action;

  const _WalletActionSheet({required this.action});

  @override
  State<_WalletActionSheet> createState() => _WalletActionSheetState();
}

class _WalletActionSheetState extends State<_WalletActionSheet> {
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  String _symbol = 'USD';
  bool _buy = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _amountCtrl.addListener(() => setState(() => _error = null));
    if (widget.action == WalletAction.convert || widget.action == WalletAction.transfer) _symbol = 'BTC';
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  // Какие активы можно выбрать в этом окне
  List<String> _options(WalletState w, List<String> coins) {
    bool held(String s) => (w.portfolioMicro[s] ?? 0) > 0;
    switch (widget.action) {
      case WalletAction.deposit:
        return ['USD', ...coins];
      case WalletAction.withdraw:
        return ['USD'];
      case WalletAction.transfer:
        return coins.where(held).toList();
      case WalletAction.convert:
        return _buy ? coins : coins.where(held).toList();
    }
  }

  String _title(AppLocalizations l10n) {
    switch (widget.action) {
      case WalletAction.deposit:
        return l10n.deposit;
      case WalletAction.withdraw:
        return l10n.withdraw;
      case WalletAction.convert:
        return l10n.convert;
      case WalletAction.transfer:
        return l10n.transfer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final wallet = context.watch<WalletCubit>().state;
    final market = context.watch<MarketCubit>().state;
    final assets = market is MarketLoaded ? market.assets : <CryptoAsset>[];
    final prices = priceMap(assets);
    final options = _options(wallet, coinSymbols(assets));

    // Если выбранного актива нет в списке (например, после смены Buy/Sell), берём первый
    _symbol = options.contains(_symbol) ? _symbol : (options.isEmpty ? '' : options.first);
    final symbol = _symbol;
    final isUsd = symbol == 'USD';
    final price = isUsd ? 1.0 : (prices[symbol] ?? 0.0);
    final action = widget.action;
    final value = double.tryParse(_amountCtrl.text) ?? 0;

    // В чём измеряется сумма в поле
    final unit = (action == WalletAction.transfer || (action == WalletAction.deposit && !isUsd)) ? symbol : 'USD';

    // Сколько доступно (в единицах поля суммы)
    String? availableText;
    double availableUnits = 0;
    switch (action) {
      case WalletAction.deposit:
        break;
      case WalletAction.withdraw:
        availableUnits = wallet.usdBalance;
        availableText = formatUsd(availableUnits);
      case WalletAction.transfer:
        availableUnits = wallet.getAssetBalance(symbol);
        availableText = '${_trim(availableUnits)} $symbol';
      case WalletAction.convert:
        availableUnits = _buy ? wallet.usdBalance : wallet.getAssetBalance(symbol) * price;
        availableText = formatUsd(availableUnits);
    }

    // Быстрые кнопки: (подпись, значение для поля)
    final chips = <(String, String)>[];
    if (action == WalletAction.deposit) {
      if (isUsd) {
        for (final v in const [100, 500, 1000, 5000]) {
          chips.add(('\$${NumberFormat('#,##0').format(v)}', '$v'));
        }
      }
    } else {
      for (final p in const [25, 50, 75, 100]) {
        chips.add(('$p%', _trim(_floorTo(availableUnits * p / 100, unit == 'USD' ? 2 : 6))));
      }
    }

    // Подсказка под полем суммы
    String? summary;
    if (value > 0 && price > 0) {
      switch (action) {
        case WalletAction.deposit:
          if (!isUsd) summary = '≈ ${formatUsd(value * price)}';
        case WalletAction.transfer:
          summary = '≈ ${formatUsd(value * price)}';
        case WalletAction.convert:
          summary = '≈ ${_trim(value / price)} $symbol';
        case WalletAction.withdraw:
          break;
      }
    }

    final accent = (action == WalletAction.convert && !_buy) ? AppColors.neonRed : AppColors.neonGreen;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_title(l10n), style: AppTypography.titleLarge),
                PressEffect(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (action == WalletAction.convert) ...[_buySellToggle(l10n), const SizedBox(height: 14)],
            if (options.length > 1) ...[_assetChips(options, symbol), const SizedBox(height: 14)],
            if (options.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(l10n.orderNoFunds, style: AppTypography.caption.copyWith(color: AppColors.neonRed)),
              ),
            if (availableText != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('${l10n.available}: $availableText', style: AppTypography.caption),
              ),
            _input('${l10n.amount} ($unit)', _amountCtrl),
            if (chips.isNotEmpty) ...[const SizedBox(height: 10), _chipsRow(chips)],
            if (action == WalletAction.transfer) ...[
              const SizedBox(height: 12),
              _input(l10n.walletAddress, _addressCtrl, decimal: false),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.networkFee, style: AppTypography.caption),
                  Text(formatUsd(kNetworkFeeUsd), style: AppTypography.bodyLarge.copyWith(fontSize: 12)),
                ],
              ),
            ],
            if (summary != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(summary, style: AppTypography.bodyLarge.copyWith(fontSize: 13, color: accent)),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_error!, style: AppTypography.caption.copyWith(color: AppColors.neonRed, fontSize: 12)),
              ),
            const SizedBox(height: 16),
            PressEffect(
              scale: 0.97,
              onTap: () => _submit(l10n: l10n, symbol: symbol, price: price, value: value),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Text(
                  _title(l10n).toUpperCase(),
                  style: AppTypography.bodyLarge.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: accent == AppColors.neonRed ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit({required AppLocalizations l10n, required String symbol, required double price, required double value}) {
    final wallet = context.read<WalletCubit>();
    String? error;
    var ok = false;

    if (symbol.isEmpty || value <= 0 || (symbol != 'USD' && price <= 0)) {
      error = l10n.invalidAmount;
    } else {
      switch (widget.action) {
        case WalletAction.deposit:
          ok = wallet.deposit(symbol, value, usdPrice: price);
        case WalletAction.withdraw:
          ok = wallet.withdraw(value);
        case WalletAction.transfer:
          if (_addressCtrl.text.trim().length < 10) {
            error = l10n.invalidAddress;
          } else {
            ok = wallet.transfer(symbol, value, usdPrice: price, fee: kNetworkFeeUsd);
          }
        case WalletAction.convert:
          final qty = value / price;
          if ((qty * 1000000).round() < 1) {
            error = l10n.invalidAmount;
          } else {
            ok = _buy ? wallet.buyAsset(symbol, qty, price) : wallet.sellAsset(symbol, qty, price);
          }
      }
      if (!ok && error == null) error = l10n.orderNoFunds;
    }

    if (error != null) {
      setState(() => _error = error);
      return;
    }

    // Успех: закрываем панель и показываем плашку на экране под ней
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.operationDone, style: const TextStyle(color: Colors.black)),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          backgroundColor: AppColors.neonGreen,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Widget _buySellToggle(AppLocalizations l10n) {
    Widget item(String label, bool buy) {
      final selected = _buy == buy;
      final color = buy ? AppColors.neonGreen : AppColors.neonRed;
      return Expanded(
        child: PressEffect(
          scale: 0.97,
          onTap: () {
            _amountCtrl.clear();
            setState(() => _buy = buy);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: selected ? color : Colors.transparent, borderRadius: BorderRadius.circular(8)),
            child: Text(
              label,
              style: AppTypography.bodyLarge.copyWith(fontSize: 13, color: selected ? (buy ? Colors.black : Colors.white) : Colors.white70),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(children: [item(l10n.buy, true), item(l10n.sell, false)]),
    );
  }

  Widget _assetChips(List<String> options, String selected) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final s = options[i];
          final isSelected = s == selected;
          return PressEffect(
            scale: 0.95,
            onTap: () {
              _amountCtrl.clear();
              setState(() => _symbol = s);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.neonGreen.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppColors.neonGreen : Colors.white.withValues(alpha: 0.12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (s == 'USD')
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.neonGreen.withValues(alpha: 0.2)),
                      child: const Icon(Icons.attach_money_rounded, size: 14, color: AppColors.neonGreen),
                    )
                  else
                    CoinIcon(symbol: s, size: 22),
                  const SizedBox(width: 6),
                  Text(s, style: AppTypography.bodyLarge.copyWith(fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _chipsRow(List<(String, String)> chips) {
    return Row(
      children: [
        for (final (label, text) in chips)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: PressEffect(
                scale: 0.94,
                onTap: () => _amountCtrl.text = text,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                  ),
                  child: Text(label, style: AppTypography.caption.copyWith(fontSize: 11, color: Colors.white70)),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _input(String label, TextEditingController controller, {bool decimal = true}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: decimal ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          inputFormatters: decimal ? [DecimalInputFormatter()] : null,
          cursorColor: AppColors.neonGreen,
          style: AppTypography.bodyLarge.copyWith(fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.35),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(borderSide: BorderSide(color: AppColors.neonGreen.withValues(alpha: 0.6))),
          ),
        ),
      ],
    );
  }
}
