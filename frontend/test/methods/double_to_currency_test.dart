import 'package:frontend/ui/commons/values/currency_format.dart';
import 'package:test/test.dart';

void main() {
  group('formatCurrency', () {
    test('formats String AA as null', () {
      expect(parseCurrencyStringToDouble('AA'), equals(null));
    });

    test('formats String 02 as double 0,02 €', () {
      expect(parseCurrencyStringToDouble('0,02 €'), equals(0.02));
    });

    test('formats String 130 as double 1,30 €', () {
      expect(parseCurrencyStringToDouble('1,30 €'), equals(1.30));
    });

    test('formats String 130 as double 1,30 €', () {
      expect(parseCurrencyStringToDouble('130,58 €'), equals(130.58));
    });

    test('formats String 1.324,52 € as double 1324.52', () {
      expect(parseCurrencyStringToDouble('1.324,52 €'), equals(1324.52));
    });

    test('formats String € 1.324,52 as double 1324.52', () {
      expect(parseCurrencyStringToDouble('€ 1.324,52'), equals(1324.52));
    });

    test('formats String 1.324,52 as double 1324.52', () {
      expect(parseCurrencyStringToDouble('1.324,52'), equals(1324.52));
    });
  });
}
