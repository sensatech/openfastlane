import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/campaign/campaigns_service.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlements_service.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_service.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class EntitlementViewViewModel extends Cubit<EntitlementViewState> {
  EntitlementViewViewModel(this._entitlementsService, this._personsService, this._campaignsService)
      : super(EntitlementViewInitial());

  final EntitlementsService _entitlementsService;
  final PersonsService _personsService;
  final CampaignsService _campaignsService;
  Logger logger = getLogger();

  Future loadEntitlement(String entitlementId, String campaignId) async {
    emit(EntitlementViewLoading());
    try {
      Entitlement entitlement = await _entitlementsService.getEntitlement(entitlementId);
      Person? person = await _personsService.getSinglePerson(entitlement.personId);
      Campaign campaign = await _campaignsService.getCampaign(campaignId);
      if (person != null) {
        logger.i('Entitlement loaded: $entitlement');
        emit(EntitlementViewLoaded(entitlement, person, campaign));
      } else {
        logger.e('Error loading entitlement - person: $person');
        emit(EntitlementViewError('Error loading entitlement: person of entitlement is null'));
      }
    } catch (e) {
      logger.e('Error loading entitlement: $e');
      emit(EntitlementViewError(e.toString()));
    }
  }
}

@immutable
abstract class EntitlementViewState extends Equatable {}

class EntitlementViewInitial extends EntitlementViewState {
  @override
  List<Object?> get props => [];
}

class EntitlementViewLoading extends EntitlementViewState {
  @override
  List<Object?> get props => [];
}

class EntitlementViewLoaded extends EntitlementViewState {
  EntitlementViewLoaded(this.entitlement, this.person, this.campaign);

  final Person person;
  final Entitlement entitlement;
  final Campaign campaign;

  @override
  List<Object?> get props => [entitlement, person, campaign];
}

class EntitlementViewError extends EntitlementViewState {
  EntitlementViewError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
