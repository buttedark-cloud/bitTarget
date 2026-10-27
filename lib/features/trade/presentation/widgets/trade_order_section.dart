import 'package:bittarget/features/trade/presentation/cubit/trade_cubit.dart';
import 'package:bittarget/features/trade/presentation/widgets/order_book.dart';
import 'package:bittarget/features/trade/presentation/widgets/order_form.dart';
import 'package:flutter/material.dart';

class TradeOrderSection extends StatefulWidget {
  final TradeState state;
  final String symbol;

  const TradeOrderSection({super.key, required this.state, required this.symbol});

  @override
  State<TradeOrderSection> createState() => _TradeOrderSectionState();
}

class _TradeOrderSectionState extends State<TradeOrderSection> {
  // Стакан кладёт сюда цену, на которую нажали, а форма её подхватывает
  final ValueNotifier<double?> _pickedPrice = ValueNotifier<double?>(null);

  @override
  void dispose() {
    _pickedPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticker = widget.state.ticker!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: OrderBookView(
            book: widget.state.orderBook,
            lastPrice: ticker.price,
            isUp: ticker.changePercent >= 0,
            onPriceTap: (p) {
              _pickedPrice.value = null; // сброс, чтобы повторное нажатие на ту же цену тоже сработало
              _pickedPrice.value = p;
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 6,
          child: OrderForm(symbol: widget.symbol, marketPrice: ticker.price, pickedPrice: _pickedPrice),
        ),
      ],
    );
  }
}
