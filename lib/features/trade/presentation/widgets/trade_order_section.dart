import 'package:bittarget/features/trade/presentation/cubit/trade_cubit.dart';
import 'package:bittarget/features/trade/presentation/widgets/order_book.dart';
import 'package:bittarget/features/trade/presentation/widgets/order_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TradeOrderSection extends StatefulWidget {
  const TradeOrderSection({super.key});

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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: RepaintBoundary(
            // Стакан: только при новых заявках или новой цене
            child: BlocBuilder<TradeCubit, TradeState>(
              buildWhen: (p, c) => p.orderBook != c.orderBook || p.ticker?.price != c.ticker?.price,
              builder: (_, s) {
                final t = s.ticker;
                if (t == null) return const SizedBox.shrink();
                return OrderBookView(
                  book: s.orderBook,
                  lastPrice: t.price,
                  isUp: t.changePercent >= 0,
                  onPriceTap: (p) {
                    _pickedPrice.value = null; // сброс, чтобы повторное нажатие на ту же цену тоже сработало
                    _pickedPrice.value = p;
                  },
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 6,
          // Форма: только при смене монеты или цены
          child: BlocBuilder<TradeCubit, TradeState>(
            buildWhen: (p, c) => p.symbol != c.symbol || p.ticker?.price != c.ticker?.price,
            builder: (_, s) {
              final t = s.ticker;
              if (t == null) return const SizedBox.shrink();
              return OrderForm(key: ValueKey(s.symbol), symbol: s.symbol, marketPrice: t.price, pickedPrice: _pickedPrice);
            },
          ),
        ),
      ],
    );
  }
}
