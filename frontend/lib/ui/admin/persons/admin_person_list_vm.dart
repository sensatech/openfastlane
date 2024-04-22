import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_service.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class AdminPersonListViewModel extends Cubit<AdminPersonListState> {
  AdminPersonListViewModel(this._personService) : super(AdminPersonListInitial());

  final PersonsService _personService;

  Logger logger = getLogger();

  Future<void> loadAllPersonsWithEntitlements({String? campaignId}) async {
    emit(AdminPersonListLoading());
    try {
      List<Person> persons = await _personService.getAllPersons();

      logger.d('loadAllPersons: iterating ${persons.length} persons');

      emit(AdminPersonListLoaded(persons));
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
  AdminPersonListLoaded(this.persons);

  final List<Person> persons;

  @override
  List<Object> get props => [persons];
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
