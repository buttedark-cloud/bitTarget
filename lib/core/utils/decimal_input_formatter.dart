import 'package:flutter/services.dart';

class DecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(',', '.');
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) return oldValue;
    return newValue.copyWith(text: text);
  }
}
