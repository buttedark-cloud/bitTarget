class Candle {
  final DateTime time;
  final double close;

  const Candle(this.time, this.close);
}

class TickerData {
  final double price;
  final double change; // изменение за 24ч в долларах
  final double changePercent; // изменение за 24ч в процентах
  final double high;
  final double low;

  const TickerData({required this.price, required this.change, required this.changePercent, required this.high, required this.low});
}

class OrderBookLevel {
  final double price;
  final double qty;

  const OrderBookLevel(this.price, this.qty);
}

class OrderBook {
  final List<OrderBookLevel> bids; // заявки на покупку, лучшая цена первой
  final List<OrderBookLevel> asks; // заявки на продажу, лучшая цена первой

  const OrderBook({required this.bids, required this.asks});
}
