import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/entitlements/entitlements_service.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_service.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class AdminPersonListViewModel extends Cubit<AdminPersonListState> {
  AdminPersonListViewModel(this._personService, this._entitlementsService) : super(AdminPersonListInitial());

  final PersonsService _personService;
  final EntitlementsService _entitlementsService;

  Logger logger = getLogger();

  Future<void> loadAllPersons() async {
    emit(AdminPersonListLoading());
    try {
      List<Person> persons = await _personService.getAllPersons();
      List<Entitlement> entitlements = await _entitlementsService.getEntitlements();
      List<EntitlementCause> campaignEntitlementCauses = await _entitlementsService.getEntitlementCauses();

      List<PersonWithEntitlement> personWithEntitlements = [];

      logger.d('loadAllPersons: iterating ${persons.length} persons with ${entitlements.length}  entitlements');

      for (var person in persons) {
        var filteredEntitlements = entitlements.where((entitlement) => entitlement.personId == person.id).toList();
        personWithEntitlements.add(PersonWithEntitlement(person, filteredEntitlements));
        // logger.d('loadAllPersons: ${person.firstName} ${person.lastName} has ${filteredEntitlements.length} entitlements');
      }

      emit(AdminPersonListLoaded(personWithEntitlements, campaignEntitlementCauses));
    } catch (e) {
      emit(AdminPersonListError(e.toString()));
    }
  }
}

@immutable
abstract class AdminPersonListState extends Equatable {}

class AdminPersonListInitial extends AdminPersonListState {
  @override
  List<Object> get props => [];
}

class AdminPersonListLoading extends AdminPersonListState {
  @override
  List<Object> get props => [];
}

class AdminPersonListLoaded extends AdminPersonListState {
  AdminPersonListLoaded(this.personsWithEntitlements, this.campaignEntitlementCauses);

  final List<PersonWithEntitlement> personsWithEntitlements;
  final List<EntitlementCause> campaignEntitlementCauses;

  @override
  List<Object> get props => [personsWithEntitlements, campaignEntitlementCauses];
}

class AdminPersonListError extends AdminPersonListState {
  AdminPersonListError(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}

// good idea! We might use that generally, so we can think about using that in the service
class PersonWithEntitlement extends Equatable {
  final Person person;
  final List<Entitlement> entitlements;

  const PersonWithEntitlement(this.person, this.entitlements);

  @override
  List<Object> get props => [person, entitlements];
}
