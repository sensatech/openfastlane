import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/campaign/campaigns_service.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlement_qr_data.dart';
import 'package:frontend/domain/entitlements/entitlements_service.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class ScannerCameraViewModel extends Cubit<ScannerCameraState> {
  ScannerCameraViewModel(this._campaignsService, this._entitlementsService) : super(ScannerCameraInitial());

  final CampaignsService _campaignsService;
  final EntitlementsService _entitlementsService;
  final Logger logger = getLogger();

  Future<void> prepare(String campaignId) async {
    emit(ScannerCameraLoading());
    try {
      final Campaign campaign = await _campaignsService.getCampaign(campaignId);
      final List<CameraDescription> cameras = await availableCameras();
      final CameraDescription camera =
          cameras.firstWhere((camera) => camera.lensDirection == CameraLensDirection.back, orElse: () => cameras.first);

      emit(ScannerCameraUiLoaded(campaign, camera));
    } catch (e) {
      emit(ScannerCameraError(errorText: e.toString(), errorType: ScannerCameraErrorType.unknownError));
    }
  }

  Future<void> checkQrCode({required String? qrCode, required String campaignId, required bool checkOnly}) async {
    if (qrCode == null) {
      _noQrCodeFound();
      return;
    }

    emit(ScannerCameraLoading());
    logger.i('url IS: $qrCode');
    try {
      QrData? qrData = QrData.fromUrl(qrCode);

      if (qrData != null) {
        logger.i(
            'QR-Code data: \nentitlementId: ${qrData.entitlementId}\nentitlementCauseId: ${qrData.entitlementCauseId}'
            '\npersonId: ${qrData.personId}\nepoch: ${qrData.epoch}');
        if (qrData.entitlementId == null) {
          logger.e('No entitlement ID in url found');
          emit(ScannerCameraError(
              errorText: 'No entitlement ID in url found', errorType: ScannerCameraErrorType.wrongFormat));
        } else {
          final Entitlement entitlement =
              await _entitlementsService.getEntitlement(qrData.entitlementId!, includeNested: true);
          if (entitlement.campaignId == campaignId) {
            emit(EntitlementFound(entitlement.id, entitlement.campaignId, checkOnly));
          } else {
            logger.e('Entitlement of wrong campaign');
            emit(ScannerCameraError(
                errorText: 'Entitlement of wrong campaign',
                errorType: ScannerCameraErrorType.entitlementOfWrongCampaign));
          }
        }
      } else {
        logger.e('Error while parsing QR code');
        emit(ScannerCameraError(
            errorText: 'Error while parsing QR code', errorType: ScannerCameraErrorType.wrongFormat));
      }
    } catch (e) {
      logger.e('error while checking qr code: $e');
      emit(ScannerCameraError(errorText: e.toString(), errorType: ScannerCameraErrorType.unknownError));
    }
  }

  Future<void> _noQrCodeFound() async {
    logger.e('No QR code found');
    emit((ScannerCameraError(errorText: 'No QR code found', errorType: ScannerCameraErrorType.noQrCodeFound)));
  }
}

class ScannerCameraState {}

class ScannerCameraInitial extends ScannerCameraState {}

class ScannerCameraLoading extends ScannerCameraState {}

class ScannerCameraUiLoaded extends ScannerCameraState {
  ScannerCameraUiLoaded(this.campaign, this.camera);

  final Campaign campaign;
  final CameraDescription camera;
}

class EntitlementFound extends ScannerCameraState {
  EntitlementFound(
    this.entitlementId,
    this.campaignId,
    this.checkOnly,
  );

  final String entitlementId;
  final String campaignId;
  final bool checkOnly;
}

class ScannerCameraError extends ScannerCameraState {
  ScannerCameraError({required this.errorText, required this.errorType});

  final String errorText;
  final ScannerCameraErrorType errorType;
}

enum ScannerCameraErrorType { noQrCodeFound, noEntitlementFound, entitlementOfWrongCampaign, wrongFormat, unknownError }
