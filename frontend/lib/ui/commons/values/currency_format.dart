import 'package:frontend/setup/logger.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

double? parseCurrencyStringToDouble(String input, {String locale = 'de_DE'}) {
  Logger logger = getLogger();
  // Create a NumberFormat that matches the formatter's configuration.
  NumberFormat format = NumberFormat.currency(locale: locale, symbol: '€', decimalDigits: 2);

  // Remove the currency symbol and trim any spaces.
  String numericString = input.replaceAll('€', '').trim();

  try {
    double value = format.parse(numericString) as double;
    return value;
  } catch (e) {
    logger.e('Error parsing number: $e');
    return null;
  }
}

int? parseStringToInt(String input, {String locale = 'de_DE'}) {
  Logger logger = getLogger();
  // Create a NumberFormat that matches the formatter's configuration.
  NumberFormat format = NumberFormat.currency(locale: locale, symbol: '€', decimalDigits: 2);

  // Remove the currency symbol and trim any spaces.
  String numericString = input.replaceAll('€', '').trim();

  try {
    int value = format.parse(numericString) as int;
    return value;
  } catch (e) {
    logger.e('Error parsing number: $e');
    return null;
  }
}