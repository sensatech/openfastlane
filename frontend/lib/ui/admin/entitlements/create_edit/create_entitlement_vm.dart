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

class CreateEntitlementViewModel extends Cubit<CreateEntitlementState> {
  CreateEntitlementViewModel(this._entitlementsService, this._personsService, this._campaignsService)
      : super(CreateEntitlementInitial());

  final EntitlementsService _entitlementsService;
  final PersonsService _personsService;
  final CampaignsService _campaignsService;

  Logger logger = getLogger();

  Future<void> prepare(String personId, String campaignId) async {
    emit(CreateEntitlementLoading());
    try {
      Person? person = await _personsService.getSinglePerson(personId);
      Campaign campaign = await _campaignsService.getCampaign(campaignId);
      List<EntitlementCause>? campaignEntitlementCauses = campaign.causes;
      if (person != null && campaignEntitlementCauses != null) {
        logger.i('person and entitlement loaded: $person');
        emit(CreateEntitlementLoaded(person, campaignEntitlementCauses, campaign));
      } else {
        emit(CreateEditEntitlementError('person or campaign is null'));
      }
    } catch (e) {
      emit(CreateEditEntitlementError(e.toString()));
    }
  }

  Future<void> createEntitlement({
    required String personId,
    required String entitlementCauseId,
    required List<EntitlementValue> values,
  }) async {
    try {
      Entitlement entitlement = await _entitlementsService.createEntitlement(personId, entitlementCauseId, values);
      Person? person = await _personsService.getSinglePerson(personId);
      if (person != null) {
        emit(CreateEntitlementEdited(person));
        await Future.delayed(const Duration(milliseconds: 1500));
        emit(CreateEntitlementCompleted(entitlement.id));
      } else {
        emit(CreateEditEntitlementError('create entitlement vm: person is null'));
      }
    } catch (e) {
      emit(CreateEditEntitlementError(e.toString()));
    }
  }
}

@immutable
abstract class CreateEntitlementState extends Equatable {}

class CreateEntitlementInitial extends CreateEntitlementState {
  @override
  List<Object?> get props => [];
}

class CreateEntitlementLoading extends CreateEntitlementState {
  @override
  List<Object?> get props => [];
}

class CreateEntitlementLoaded extends CreateEntitlementState {
  final Person person;
  final List<EntitlementCause> entitlementCauses;
  final Entitlement? entitlement;
  final Campaign campaign;

  CreateEntitlementLoaded(this.person, this.entitlementCauses, this.campaign, {this.entitlement});

  @override
  List<Object?> get props => [person, entitlementCauses, entitlement];
}

class CreateEntitlementEdited extends CreateEntitlementState {
  final Person person;

  CreateEntitlementEdited(this.person);

  @override
  List<Object?> get props => [person];
}

class CreateEntitlementCompleted extends CreateEntitlementState {
  CreateEntitlementCompleted(this.entitlementId);

  final String entitlementId;

  @override
  List<Object?> get props => [];
}

class CreateEditEntitlementError extends CreateEntitlementState {
  CreateEditEntitlementError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
