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

  Future<void> prepareForEdit(String personId, String entitlementId) async {
    emit(ExistingEntitlementLoading());
    try {
      Person? person = await _personsService.getSinglePerson(personId);
      Entitlement entitlement = await _entitlementsService.getEntitlement(entitlementId);
      Campaign campaign = await _campaignsService.getCampaign(entitlement.campaignId);
      List<EntitlementCause>? campaignEntitlementCauses = campaign.causes;
      if (person != null && campaignEntitlementCauses != null) {
        logger.i('campaigns entitlement causes loaded: $campaignEntitlementCauses');
        emit(ExistingEntitlementLoaded(person, campaignEntitlementCauses, campaign, entitlement: entitlement));
      } else {
        emit(EditEntitlementError('prepare entitlement vm: person is null'));
      }
    } catch (e) {
      emit(EditEntitlementError(e.toString()));
    }
  }

  // edit an existing entitlement
  Future<void> editEntitlement({
    required String entitlementId,
    required List<EntitlementValue> values,
  }) async {
    try {
      await _entitlementsService.updateEntitlement(entitlementId, values);
      // emit(EntitlementEdited());
      // await Future.delayed(const Duration(milliseconds: 1500));
      emit(EditEntitlementCompleted());
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

class ExistingEntitlementLoading extends EditEntitlementState {
  @override
  List<Object?> get props => [];
}

class ExistingEntitlementLoaded extends EditEntitlementState {
  final Person person;
  final List<EntitlementCause> entitlementCauses;
  final Entitlement? entitlement;
  final Campaign campaign;

  ExistingEntitlementLoaded(this.person, this.entitlementCauses, this.campaign, {this.entitlement});

  @override
  List<Object?> get props => [person, entitlementCauses, entitlement];
}

class EntitlementEdited extends EditEntitlementState {
  EntitlementEdited();

  @override
  List<Object?> get props => [];
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
