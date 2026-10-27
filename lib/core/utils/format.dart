import 'package:intl/intl.dart';

int _decimalsFor(double value) => value >= 1 ? 2 : (value >= 0.01 ? 4 : 6);

/// $80,520.01  ·  $0.0914  ·  $0.000012
String formatUsd(double value) {
  return NumberFormat.currency(locale: 'en_US', symbol: r'$', decimalDigits: _decimalsFor(value)).format(value);
}

/// 80520.01  ·  0.0914 (без знака доллара и запятых)
String formatPrice(double value) => value.toStringAsFixed(_decimalsFor(value));
