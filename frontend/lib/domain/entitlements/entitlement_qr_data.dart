import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class QrData {
  final String? entitlementCauseId;
  final String? personId;
  final String? entitlementId;
  final String? epoch;

  QrData({required this.entitlementCauseId, required this.personId, required this.entitlementId, required this.epoch});

  // Factory method to create an instance of QRData from a URL
  static QrData? fromUrl(String url) {
    final Logger logger = getLogger();
    try {
      Uri uri = Uri.parse(url);
      String pathSegment = uri.pathSegments.last;
      List<String> values = pathSegment.split('-');

      if (values.length != 4) {
        throw const FormatException("URL does not contain the expected four parts");
      }

      return QrData(
        entitlementCauseId: values[0],
        personId: values[1],
        entitlementId: values[2],
        epoch: values[3],
      );
    } catch (e) {
      logger.e('Error while parsing QR code: $e');
      return null;
    }
  }
}
