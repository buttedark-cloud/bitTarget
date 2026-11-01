import 'package:bittarget/core/constants/app_colors.dart';
import 'package:bittarget/core/theme/app_typography.dart';
import 'package:bittarget/core/utils/decimal_input_formatter.dart';
import 'package:bittarget/core/utils/format.dart';
import 'package:bittarget/core/widgets/glass_card.dart';
import 'package:bittarget/core/widgets/press_effect.dart';
import 'package:bittarget/features/wallet/cubit/wallet_cubit.dart';
import 'package:bittarget/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderForm extends StatefulWidget {
  final String symbol;
  final double marketPrice;
  final ValueNotifier<double?> pickedPrice; // сюда стакан кладёт цену, на которую нажали

  const OrderForm({super.key, required this.symbol, required this.marketPrice, required this.pickedPrice});

  @override
  State<OrderForm> createState() => _OrderFormState();
}

class _OrderFormState extends State<OrderForm> {
  late final TextEditingController _priceCtrl;
  final TextEditingController _amountCtrl = TextEditingController();
  bool _isBuy = true;
  bool _isMarket = false;

  @override
  void initState() {
    super.initState();
    _priceCtrl = TextEditingController(text: formatPrice(widget.marketPrice));
    _priceCtrl.addListener(_refresh);
    _amountCtrl.addListener(_refresh);
    widget.pickedPrice.addListener(_onPicked);
  }

  @override
  void dispose() {
    widget.pickedPrice.removeListener(_onPicked);
    _priceCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  // Цена, с которой работает форма: рыночная (живая) или введённая вручную
  double get _priceValue => _isMarket ? widget.marketPrice : (double.tryParse(_priceCtrl.text) ?? 0);

  void _onPicked() {
    final p = widget.pickedPrice.value;
    if (p == null) return;
    _priceCtrl.text = formatPrice(p);
    if (_isMarket) setState(() => _isMarket = false); // выбрали свою цену, значит это лимитный ордер
  }

  // Проценты от баланса, с округлением вниз до 6 знаков (столько хранит кошелёк)
  void _applyPercent(double fraction) {
    final wallet = context.read<WalletCubit>().state;
    final price = _priceValue;
    int micro;

    if (_isBuy) {
      final priceCents = (price * 100).round();
      if (priceCents <= 0) return;
      micro = (wallet.usdBalanceCents * fraction * 1000000 / priceCents).floor();
    } else {
      micro = ((wallet.portfolioMicro[widget.symbol] ?? 0) * fraction).floor();
    }

    _amountCtrl.text = micro <= 0 ? '' : (micro / 1000000).toStringAsFixed(6).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    final price = _priceValue;
    final amount = double.tryParse(_amountCtrl.text);

    if (amount == null || price <= 0 || (amount * 1000000).round() < 1) {
      _toast(l10n.orderInvalid);
      return;
    }

    // Для лимитного ордера: защита от «цены с потолка», не дальше 5% от рынка
    if (!_isMarket && (price - widget.marketPrice).abs() / widget.marketPrice > 0.05) {
      _toast(l10n.orderPriceFar);
      return;
    }

    final wallet = context.read<WalletCubit>();
    final ok = _isBuy ? wallet.buyAsset(widget.symbol, amount, price) : wallet.sellAsset(widget.symbol, amount, price);

    if (ok) {
      _amountCtrl.clear();
      _toast(l10n.orderFilled, success: true);
    } else {
      _toast(l10n.orderNoFunds);
    }
  }

  void _toast(String text, {bool success = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text, style: TextStyle(color: success ? Colors.black : Colors.white)),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 100), // чтобы не закрывать нижнее меню
          backgroundColor: success ? AppColors.neonGreen : const Color(0xFF2A2A2E),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _setMarket(bool market) {
    // Возвращаясь к лимитному режиму, подставляем текущую рыночную цену как стартовую
    if (!market) _priceCtrl.text = formatPrice(widget.marketPrice);
    setState(() => _isMarket = market);
  }

  void _showOrderTypeSheet() {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121214),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.orderType, style: AppTypography.titleLarge),
              const SizedBox(height: 14),
              _typeOption(sheetContext, l10n.limitOrder, l10n.limitDesc, market: false),
              const SizedBox(height: 10),
              _typeOption(sheetContext, l10n.marketOrder, l10n.marketDesc, market: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeOption(BuildContext sheetContext, String title, String desc, {required bool market}) {
    final selected = _isMarket == market;

    return PressEffect(
      scale: 0.98,
      onTap: () {
        _setMarket(market);
        Navigator.pop(sheetContext);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.neonGreen.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.neonGreen : Colors.white.withValues(alpha: 0.10)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.bodyLarge.copyWith(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(desc, style: AppTypography.caption.copyWith(fontSize: 11)),
                ],
              ),
            ),
            if (selected)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.check_circle_rounded, color: AppColors.neonGreen),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final price = _priceValue;
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    final accent = _isBuy ? AppColors.neonGreen : AppColors.neonRed;

    return GlassCard(
      radius: 16,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sideToggle(l10n),
          const SizedBox(height: 14),
          // Тип ордера: нажми, чтобы выбрать лимитный или рыночный
          PressEffect(
            scale: 0.98,
            onTap: _showOrderTypeSheet,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_isMarket ? l10n.marketOrder : l10n.limitOrder, style: AppTypography.bodyLarge.copyWith(fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(_isMarket ? l10n.marketHint : l10n.limitHint, style: AppTypography.caption.copyWith(fontSize: 10)),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.neonGreen, size: 22),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (_isMarket) _marketPriceBox(l10n.marketPrice) else _field(l10n.priceUsdt, _priceCtrl),
          const SizedBox(height: 12),
          _field('${l10n.amount} (${widget.symbol})', _amountCtrl),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final p in const [25, 50, 75, 100])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: PressEffect(
                      scale: 0.94,
                      onTap: () => _applyPercent(p / 100),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                        ),
                        child: Text('$p%', style: AppTypography.caption.copyWith(fontSize: 10, color: Colors.white70)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${l10n.total}:', style: AppTypography.caption),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    formatUsd(price * amount),
                    style: AppTypography.bodyLarge.copyWith(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PressEffect(
            scale: 0.97,
            onTap: _submit,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Text(
                '${(_isBuy ? l10n.buy : l10n.sell).toUpperCase()} ${widget.symbol}',
                style: AppTypography.bodyLarge.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _isBuy ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // В рыночном режиме цену не вводят: показываем живую рыночную
  Widget _marketPriceBox(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(formatPrice(widget.marketPrice), style: AppTypography.bodyLarge.copyWith(fontSize: 14, color: Colors.white70)),
              const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sideToggle(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Expanded(child: _sideButton(l10n.buy, true)),
          Expanded(child: _sideButton(l10n.sell, false)),
        ],
      ),
    );
  }

  Widget _sideButton(String label, bool buy) {
    final selected = _isBuy == buy;
    final color = buy ? AppColors.neonGreen : AppColors.neonRed;

    return PressEffect(
      scale: 0.96,
      onTap: () => setState(() => _isBuy = buy),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: selected ? color : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Text(
          label,
          style: AppTypography.bodyLarge.copyWith(fontSize: 13, color: selected ? (buy ? Colors.black : Colors.white) : Colors.white70),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController controller) {
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [DecimalInputFormatter()],
          cursorColor: AppColors.neonGreen,
          style: AppTypography.bodyLarge.copyWith(fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.35),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(borderSide: BorderSide(color: AppColors.neonGreen.withValues(alpha: 0.6))),
          ),
        ),
      ],
    );
  }
}
