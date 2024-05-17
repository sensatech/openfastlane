import 'package:frontend/domain/entitlements/entitlement_qr_data.dart';
import 'package:test/test.dart';

void main() {
  group('QrData fromUrl', () {
    // Tests for formatInitialValue function
    test('should parse full url with #', () {
      final qrCode = QrData.fromUrl(
          'https://ofl-test.volkshile-wien.at/#/app/qr/65cb6c1851090750aaaaabbb0-66448ec9c52c9d714626356f-66448f34c52c9d7146263570-1715783728');
      expect(qrCode, isNotNull);
    });

    test('should parse full url without #', () {
      final qrCode = QrData.fromUrl(
          'https://ofl-test.volkshile-wien.at/app/qr/65cb6c1851090750aaaaabbb0-66448ec9c52c9d714626356f-66448f34c52c9d7146263570-1715783728');
      expect(qrCode, isNotNull);
    });
  });
}
