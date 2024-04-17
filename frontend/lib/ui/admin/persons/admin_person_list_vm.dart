import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
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

  Future<void> loadAllPersonsWithEntitlements({String? campaignId}) async {
    emit(AdminPersonListLoading());
    try {
      List<Person> persons = await _personService.getAllPersons();
      //TODO: filter for campaign entitlements only
      //TODO: would be nice to have an API endpoint to get entitlements of campaign with campaignId as input parameter
      List<Entitlement> entitlements = await _entitlementsService.getEntitlements();

      List<PersonWithEntitlement> personWithEntitlements = [];

      logger.d('loadAllPersons: iterating ${persons.length} persons with ${entitlements.length}  entitlements');

      for (Person person in persons) {
        List<Entitlement> personEntitlements = entitlements.where((element) => person.id == element.personId).toList();
        personWithEntitlements.add(PersonWithEntitlement(person, personEntitlements));
      }

      emit(AdminPersonListLoaded(personWithEntitlements));
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
  AdminPersonListLoaded(this.personsWithEntitlements);

  final List<PersonWithEntitlement> personsWithEntitlements;

  @override
  List<Object> get props => [personsWithEntitlements];
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
