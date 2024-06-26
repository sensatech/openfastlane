import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class FloatInputFormatter extends TextInputFormatter {
  final NumberFormat _format;

  FloatInputFormatter({String locale = 'de_DE'})
      : _format = NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: 2);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return const TextEditingValue();
    }

    // Remove everything except digits to handle deletion of currency symbol and other characters.
    String numericString = newValue.text.replaceAll(RegExp('[^0-9]'), '');

    if (numericString.isEmpty) {
      return const TextEditingValue(text: '');
    }

    double? value = double.tryParse(numericString);
    if (value == null) {
      return oldValue;
    }

    String formattedString = _format.format(value / 100);
    // cursor position always behind the last digit and before the currency symbol
    int cursorPosition = formattedString.length - 2;
    // Trim any leading or trailing spaces (and now the symbol is part of formatting so it won't be removed here).
    formattedString = formattedString.trim();

    return TextEditingValue(
      text: formattedString,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }

  // Utility function to format a given double value using the above formatter
  String formatInitialValue(double initialValue) {
    TextEditingValue formattedValue = formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(text: initialValue.toStringAsFixed(2).replaceAll('.', '')),
    );
    return normalizeSpace(formattedValue.text);
  }
}

String normalizeSpace(String input) {
  return input.replaceAll('\u00A0', ' '); // Replace non-breaking spaces with regular spaces
}
