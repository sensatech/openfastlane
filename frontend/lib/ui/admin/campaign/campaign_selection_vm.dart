import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/campaign/campaigns_api.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class CampaignSelectionViewModel extends Cubit<CampaignSelectionState> {
  CampaignSelectionViewModel(this._campaignsApi) : super(CampaignSelectionInitial());

  final CampaignsApi _campaignsApi;

  Logger logger = getLogger();

  Future<void> loadCampaigns() async {
    emit(CampaignSelectionLoading());
    try {
      final List<Campaign> campaigns = await _campaignsApi.getAllCampaigns();
      emit(CampaignSelectionLoaded(campaigns));
    } catch (e) {
      logger.e('Error while fetching campaigns: $e');
      emit(CampaignSelectionError(e.toString()));
    }
  }
}

abstract class CampaignSelectionState {}

class CampaignSelectionInitial extends CampaignSelectionState {}

class CampaignSelectionLoading extends CampaignSelectionState {}

class CampaignSelectionLoaded extends CampaignSelectionState {
  CampaignSelectionLoaded(this.campaigns);

  final List<Campaign> campaigns;
}

class CampaignSelectionError extends CampaignSelectionState {
  CampaignSelectionError(this.error);

  final String error;
}
