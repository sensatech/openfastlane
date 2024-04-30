import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/campaign/campaigns_api.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlements_api.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class ScannerCameraViewModel extends Cubit<ScannerCameraState> {
  ScannerCameraViewModel(this._campaignsApi, this._entitlementsApi) : super(ScannerCameraInitial());

  final CampaignsApi _campaignsApi;
  final EntitlementsApi _entitlementsApi;
  final Logger logger = getLogger();

  Future<void> prepare(String campaignId) async {
    emit(ScannerCameraLoading());
    try {
      final Campaign campaign = await _campaignsApi.getCampaign(campaignId);
      emit(ScannerCameraUiLoaded(campaign));
    } catch (e) {
      emit(ScannerCameraError(e.toString()));
    }
  }

  Future<void> checkQrCode({required String qrCode, required String campaignId}) async {
    emit(ScannerCameraLoading());
    logger.i('checking qr code: $qrCode');
    try {
      // TODO: parse qr code and extract entitlementId

      String entitlementId = qrCode;
      entitlementId = '65cb6c1851090750dddd0004';

      Entitlement entitlement = await _entitlementsApi.getEntitlement(entitlementId);
      if (entitlement.campaignId == campaignId) {
        emit(EntitlementFound(entitlement.id, entitlement.campaignId));
      } else {
        emit(EntitlementOfWrongCampaign());
      }
    } catch (e) {
      logger.e('error while checking qr code: $e');
    }
  }
}

class ScannerCameraState {}

class ScannerCameraInitial extends ScannerCameraState {}

class ScannerCameraLoading extends ScannerCameraState {}

class ScannerCameraUiLoaded extends ScannerCameraState {
  ScannerCameraUiLoaded(this.campaign);

  final Campaign campaign;
}

class EntitlementFound extends ScannerCameraState {
  EntitlementFound(this.entitlementId, this.campaignId);

  final String entitlementId;
  final String campaignId;
}

class EntitlementOfWrongCampaign extends ScannerCameraState {}

class ScannerCameraError extends ScannerCameraState {
  ScannerCameraError(this.error);

  final String error;
}
