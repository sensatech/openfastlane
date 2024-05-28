import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/campaign/campaigns_service.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class CampaignSelectionViewModel extends Cubit<CampaignSelectionState> {
  CampaignSelectionViewModel(this._campaignsService) : super(CampaignSelectionInitial());

  final CampaignsService _campaignsService;

  Logger logger = getLogger();

  Future<void> loadCampaigns() async {
    emit(CampaignSelectionLoading());
    try {
      final List<Campaign> campaigns = await _campaignsService.getCampaigns();
      emit(CampaignSelectionLoaded(campaigns));
    } on Exception catch (e) {
      logger.e('Error while fetching campaigns: $e');
      emit(CampaignSelectionError(e));
    }
  }
}

@immutable
abstract class CampaignSelectionState extends Equatable {}

class CampaignSelectionInitial extends CampaignSelectionState {
  @override
  List<Object?> get props => [];
}

class CampaignSelectionLoading extends CampaignSelectionState {
  @override
  List<Object?> get props => [];
}

class CampaignSelectionLoaded extends CampaignSelectionState {
  CampaignSelectionLoaded(this.campaigns);

  final List<Campaign> campaigns;

  @override
  List<Object?> get props => [campaigns];
}

class CampaignSelectionError extends CampaignSelectionState {
  CampaignSelectionError(this.error);

  final Exception error;

  @override
  List<Object?> get props => [error];
}
