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

class EditEntitlementViewModel extends Cubit<EditEntitlementState> {
  EditEntitlementViewModel(this._entitlementsService, this._personsService, this._campaignsService)
      : super(EditEntitlementInitial());

  final EntitlementsService _entitlementsService;
  final PersonsService _personsService;
  final CampaignsService _campaignsService;

  Logger logger = getLogger();

  Future<void> prepareForEdit(String personId, String entitlementId, String campaignId) async {
    emit(EditEntitlementLoading());
    try {
      Person? person = await _personsService.getSinglePerson(personId);
      Entitlement entitlement = await _entitlementsService.getEntitlement(entitlementId);
      logger.i('person: $person \nand entitlement: $entitlement loaded');
      Campaign campaign = await _campaignsService.getCampaign(campaignId);
      if (person != null) {
        List<EntitlementCause> allEntitlementCauses = await _entitlementsService.getEntitlementCauses();
        List<EntitlementCause> campaignEntitlementCauses =
            allEntitlementCauses.where((cause) => cause.campaignId == campaign.id).toList();
        logger.i('campaigns entitlement causes loaded: $campaignEntitlementCauses');
        emit(EditEntitlementLoaded(person, campaignEntitlementCauses, campaign, entitlement: entitlement));
      } else {
        emit(EditEntitlementError('prepare entitlement vm: person or campaign is null'));
      }
    } catch (e) {
      emit(EditEntitlementError(e.toString()));
    }
  }

  // TODO: exchange with "edit entitlement"
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
        emit(EditEntitlementEdited(person));
        await Future.delayed(const Duration(milliseconds: 1500));
        emit(EditEntitlementCompleted());
      } else {
        emit(EditEntitlementError('create entitlement vm: person is null'));
      }
      //show success message and wait for 1500 milliseconds
    } catch (e) {
      emit(EditEntitlementError(e.toString()));
    }
  }

// edit an entitlement
}

@immutable
abstract class EditEntitlementState extends Equatable {}

class EditEntitlementInitial extends EditEntitlementState {
  @override
  List<Object?> get props => [];
}

class EditEntitlementLoading extends EditEntitlementState {
  @override
  List<Object?> get props => [];
}

class EditEntitlementLoaded extends EditEntitlementState {
  final Person person;
  final List<EntitlementCause> entitlementCauses;
  final Entitlement? entitlement;
  final Campaign campaign;

  EditEntitlementLoaded(this.person, this.entitlementCauses, this.campaign, {this.entitlement});

  @override
  List<Object?> get props => [person, entitlementCauses, entitlement];
}

class EditEntitlementEdited extends EditEntitlementState {
  final Person person;

  EditEntitlementEdited(this.person);

  @override
  List<Object?> get props => [person];
}

class EditEntitlementCompleted extends EditEntitlementState {
  EditEntitlementCompleted();

  @override
  List<Object?> get props => [];
}

class EditEntitlementError extends EditEntitlementState {
  EditEntitlementError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
