import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/campaign/campaigns_api.dart';

class ScannerCameraViewModel extends Cubit<ScannerCameraState> {
  ScannerCameraViewModel(this._api) : super(ScannerCameraInitial());

  final CampaignsApi _api;

  Future<void> prepare(String campaignId) async {
    emit(ScannerCameraLoading());
    try {
      final Campaign campaign = await _api.getCampaign(campaignId);
      emit(ScannerCameraUiLoaded(campaign));
    } catch (e) {
      emit(ScannerCameraError(e.toString()));
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
  EntitlementFound(this.entitlementId);
  final String entitlementId;
}

class ScannerCameraError extends ScannerCameraState {
  ScannerCameraError(this.error);

  final String error;
}
