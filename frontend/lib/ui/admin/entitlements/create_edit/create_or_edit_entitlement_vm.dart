import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/campaign/campaigns_service.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/entitlements/entitlement_value.dart';
import 'package:frontend/domain/entitlements/entitlements_service.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_service.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class CreateOrEditEntitlementViewModel extends Cubit<CreateOrEditEntitlementState> {
  CreateOrEditEntitlementViewModel(this._entitlementsService, this._personsService, this._campaignsService)
      : super(CreateOrEditEntitlementInitial());

  final EntitlementsService _entitlementsService;
  final PersonsService _personsService;
  final CampaignsService _campaignsService;

  Logger logger = getLogger();

  Future<void> prepare(String personId, String campaignId) async {
    emit(CreateOrEditEntitlementLoading());
    try {
      Campaign campaign = await _campaignsService.getCampaign(campaignId);
      Person? person = await _personsService.getSinglePerson(personId);
      if (person != null) {
        List<EntitlementCause> allEntitlementCauses = await _entitlementsService.getEntitlementCauses();
        List<EntitlementCause> campaignEntitlementCauses =
            allEntitlementCauses.where((cause) => cause.campaignId == campaign.id).toList();
        logger.i('person and entitlement loaded: $person');
        emit(CreateOrEditEntitlementLoaded(person, campaignEntitlementCauses, campaign));
      } else {
        emit(CreateOrEditEntitlementError('person or campaign is null'));
      }
    } catch (e) {
      emit(CreateOrEditEntitlementError(e.toString()));
    }
  }

  Future<void> prepareForEdit(String personId, String entitlementId, String campaignId) async {
    emit(CreateOrEditEntitlementLoading());
    try {
      Campaign campaign = await _campaignsService.getCampaign(campaignId);
      Person? person = await _personsService.getSinglePerson(personId);
      Entitlement entitlement = await _entitlementsService.getEntitlement(entitlementId);
      if (person != null) {
        List<EntitlementCause> allEntitlementCauses = await _entitlementsService.getEntitlementCauses();
        List<EntitlementCause> campaignEntitlementCauses =
            allEntitlementCauses.where((cause) => cause.campaignId == campaign.id).toList();
        logger.i('person and entitlement loaded: $person');
        emit(CreateOrEditEntitlementLoaded(person, campaignEntitlementCauses, campaign, entitlement: entitlement));
      } else {
        emit(CreateOrEditEntitlementError('prepare entitlement vm: person or campaign is null'));
      }
    } catch (e) {
      emit(CreateOrEditEntitlementError(e.toString()));
    }
  }

  // create a new entitlement
  Future<void> createEntitlement({
    required String personId,
    required String entitlementCauseId,
    required List<EntitlementValue> values,
  }) async {
    try {
      await _entitlementsService.createEntitlement(personId, entitlementCauseId, values);
      Person? person = await _personsService.getSinglePerson(personId);
      if (person != null) {
        emit(CreateOrEntitlementEdited(person));
        await Future.delayed(const Duration(milliseconds: 1500));
        emit(CreateOrEntitlementCompleted());
      } else {
        emit(CreateOrEditEntitlementError('create entitlement vm: person is null'));
      }
      //show success message and wait for 1500 milliseconds
    } catch (e) {
      emit(CreateOrEditEntitlementError(e.toString()));
    }
  }

// edit an entitlement
}

@immutable
abstract class CreateOrEditEntitlementState extends Equatable {}

class CreateOrEditEntitlementInitial extends CreateOrEditEntitlementState {
  @override
  List<Object?> get props => [];
}

class CreateOrEditEntitlementLoading extends CreateOrEditEntitlementState {
  @override
  List<Object?> get props => [];
}

class CreateOrEditEntitlementLoaded extends CreateOrEditEntitlementState {
  final Person person;
  final List<EntitlementCause> entitlementCauses;
  final Entitlement? entitlement;
  final Campaign campaign;

  CreateOrEditEntitlementLoaded(this.person, this.entitlementCauses, this.campaign, {this.entitlement});

  @override
  List<Object?> get props => [person, entitlementCauses, entitlement];
}

class CreateOrEntitlementEdited extends CreateOrEditEntitlementState {
  final Person person;

  CreateOrEntitlementEdited(this.person);

  @override
  List<Object?> get props => [person];
}

class CreateOrEntitlementCompleted extends CreateOrEditEntitlementState {
  CreateOrEntitlementCompleted();

  @override
  List<Object?> get props => [];
}

class CreateOrEditEntitlementError extends CreateOrEditEntitlementState {
  CreateOrEditEntitlementError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
