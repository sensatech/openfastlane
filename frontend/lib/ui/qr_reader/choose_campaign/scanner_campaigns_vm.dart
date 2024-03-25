import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/campaign/campaigns_api.dart';

class ScannerCampaignsViewModel extends Cubit<ScannerCampaignsViewState> {
  ScannerCampaignsViewModel(this._api) : super(ChooseCampaignInitial());

  final CampaignsApi _api;

  Future<void> prepare() async {
    try {
      final List<Campaign> campaigns = await _api.getAllCampaigns();
      emit(ChooseCampaignLoaded(campaigns));
    } catch (e) {
      emit(PersonViewError(e.toString()));
    }
  }
}

class ScannerCampaignsViewState {}

class ChooseCampaignInitial extends ScannerCampaignsViewState {}

class ChooseCampaignLoaded extends ScannerCampaignsViewState {
  ChooseCampaignLoaded(this.campaigns);

  final List<Campaign> campaigns;
}

class PersonViewError extends ScannerCampaignsViewState {
  PersonViewError(this.error);

  final String error;
}
