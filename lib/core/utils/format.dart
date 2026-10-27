import 'package:intl/intl.dart';

String formatUsd(double value) {
  final decimals = value >= 1 ? 2 : (value >= 0.01 ? 4 : 6);
  return NumberFormat.currency(locale: 'en_US', symbol: r'$', decimalDigits: decimals).format(value);
}
