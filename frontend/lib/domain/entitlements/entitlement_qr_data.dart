import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class QrData {
  final String entitlementCauseId;
  final String? personId;
  final String? entitlementId;
  final String? epoch;

  QrData({required this.entitlementCauseId, required this.personId, required this.entitlementId, required this.epoch});

  // Factory method to create an instance of QRData from a URL
  static QrData? fromUrl(String url) {
    final Logger logger = getLogger();

    String? getValue(List<String> values, int index) {
      try {
        return values[index];
      } on Exception catch (e) {
        logger.e('Error while parsing QR code: $e', error: e);
        return null;
      }
    }

    try {
      Uri uri = Uri.parse(url);
      String pathSegment = uri.toString().split('/').last;
      List<String> values = pathSegment.split('-');

      String entitlementCauseId = getValue(values, 0)!;
      String personId = getValue(values, 1)!;
      String entitlementId = getValue(values, 2)!;
      String? epoch = getValue(values, 3);

      return QrData(
        entitlementCauseId: entitlementCauseId,
        personId: personId,
        entitlementId: entitlementId,
        epoch: epoch,
      );
    } on Exception catch (e) {
      logger.e('Error while parsing QR code: $e', error: e);
      return null;
    }
  }
}
