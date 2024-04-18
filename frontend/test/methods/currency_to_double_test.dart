import 'package:frontend/ui/admin/entitlements/create_edit/currency_input_formatter.dart';
import 'package:test/test.dart';

void main() {
  group('Currency Formatting with CurrencyInputFormatter', () {
    // Tests for formatInitialValue function
    test('formats 0 correctly as "0,00 €"', () {
      expect(formatInitialValue(0), equals('0,00 €'));
    });

    test('formats 1.5 correctly as "1,50 €"', () {
      expect(formatInitialValue(1.5), equals('1,50 €'));
    });

    test('formats -1.5 correctly as "-1,50 €"', () {
      expect(formatInitialValue(-1.5), equals('1,50 €'));
    });

    test('formats 999 correctly as "999,00 €"', () {
      expect(formatInitialValue(999), equals('999,00 €'));
    });

    test('formats 1000 correctly as "1.000,00 €"', () {
      expect(formatInitialValue(1000), equals('1.000,00 €'));
    });

    test('formats 1234567.89 correctly as "1.234.567,89 €"', () {
      expect(formatInitialValue(1234567.89), equals('1.234.567,89 €'));
    });

    test('formats 0.001 correctly as "0,00 €" (testing rounding)', () {
      expect(formatInitialValue(0.001), equals('0,00 €'));
    });

    test('formats 0.009 correctly as "0,01 €" (testing rounding)', () {
      expect(formatInitialValue(0.009), equals('0,01 €'));
    });

    test('formats 999.999 correctly as "1.000,00 €" (testing rounding)', () {
      expect(formatInitialValue(999.999), equals('1.000,00 €'));
    });

    test('formats -0.01 correctly as "-0,01 €"', () {
      expect(formatInitialValue(-0.01), equals('0,01 €'));
    });

    // Ensure it handles large negative values correctly
    test('formats -1000000.50 correctly as "-1.000.000,50 €"', () {
      expect(formatInitialValue(-1000000.50), equals('1.000.000,50 €'));
    });
  });
}
