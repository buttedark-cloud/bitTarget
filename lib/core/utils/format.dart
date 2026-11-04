import 'package:intl/intl.dart';

// Знаков после запятой: 2 для нуля и цен от $1, больше для дешёвых монет
int _decimalsFor(double value) {
  final v = value.abs();
  if (v == 0 || v >= 1) return 2;
  return v >= 0.01 ? 4 : 6;
}

/// $80,520.01  ·  $0.0914  ·  $0.000012  ·  $0.00
String formatUsd(double value) {
  return NumberFormat.currency(locale: 'en_US', symbol: r'$', decimalDigits: _decimalsFor(value)).format(value);
}

/// 80520.01  ·  0.0914 (без знака доллара и запятых)
String formatPrice(double value) => value.toStringAsFixed(_decimalsFor(value));
