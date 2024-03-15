import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/entitlements/entitlement_value.dart';
import 'package:frontend/domain/entitlements/entitlements_service.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_service.dart';
import 'package:frontend/domain/user/global_user_service.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class EditEntitlementViewModel extends Cubit<EditEntitlementState> {
  EditEntitlementViewModel(this._entitlementsService, this._personsService, this._globalUserService)
      : super(EditEntitlementInitial());

  final EntitlementsService _entitlementsService;
  final PersonsService _personsService;
  final GlobalUserService _globalUserService;

  Logger logger = getLogger();

  late Person _person;
  late List<EntitlementCause> _entitlementCauses;

  Future<void> prepare(String personId) async {
    emit(EditEntitlementLoading());
    try {
      Campaign? campaign = _globalUserService.currentCampaign;
      Person? person = await _personsService.getSinglePerson(personId);
      if (campaign != null && person != null) {
        _person = person;
        List<EntitlementCause> allEntitlementCauses = await _entitlementsService.getEntitlementCauses();
        List<EntitlementCause> campaignEntitlementCauses =
            allEntitlementCauses.where((cause) => cause.campaignId == campaign.id).toList();
        _entitlementCauses = campaignEntitlementCauses;
        logger.i('person and entitlement loaded: $person');
        emit(EditEntitlementLoaded(_person, _entitlementCauses));
      }
    } catch (e) {
      emit(EditEntitlementError(e.toString()));
    }
  }

  Future<void> prepareForEdit(String personId, String entitlementId) async {
    emit(EditEntitlementLoading());
    try {
      Campaign? campaign = _globalUserService.currentCampaign;
      Person? person = await _personsService.getSinglePerson(personId);
      Entitlement entitlement = await _entitlementsService.getEntitlement(entitlementId);
      if (campaign != null && person != null) {
        _person = person;
        List<EntitlementCause> allEntitlementCauses = await _entitlementsService.getEntitlementCauses();
        List<EntitlementCause> campaignEntitlementCauses =
            allEntitlementCauses.where((cause) => cause.campaignId == campaign.id).toList();
        _entitlementCauses = campaignEntitlementCauses;
        logger.i('person and entitlement loaded: $person');
        emit(EditEntitlementLoaded(_person, _entitlementCauses, entitlement: entitlement));
      }
    } catch (e) {
      emit(EditEntitlementError(e.toString()));
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
      emit(EntitlementEdited(_person, _entitlementCauses));
      //show success message and wait for 1500 milliseconds
      await Future.delayed(const Duration(milliseconds: 1500));
      emit(EntitlementCompleted());
    } catch (e) {
      emit(EditEntitlementError(e.toString()));
    }
  }

// edit an entitlement
}

abstract class EditEntitlementState {}

class EditEntitlementInitial extends EditEntitlementState {}

class EditEntitlementLoading extends EditEntitlementState {}

class EditEntitlementLoaded extends EditEntitlementState {
  final Person person;
  final List<EntitlementCause> entitlementCauses;
  final Entitlement? entitlement;

  EditEntitlementLoaded(this.person, this.entitlementCauses, {this.entitlement});
}

class EntitlementEdited extends EditEntitlementState {
  final Person person;
  final List<EntitlementCause> entitlementCauses;

  EntitlementEdited(this.person, this.entitlementCauses);
}

class EntitlementCompleted extends EditEntitlementState {
  EntitlementCompleted();
}

class EditEntitlementError extends EditEntitlementState {
  EditEntitlementError(this.message);

  final String message;
}
