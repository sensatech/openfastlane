import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/apps/admin/person/person_model.dart';
import 'package:frontend/domain/apps/admin/person/person_service.dart';

class AdminPersonListViewModel extends Cubit<AdminPersonListState> {
  AdminPersonListViewModel(super.initialState, this.personService);

  final PersonService personService;

  Future<void> getAllPersons() async {
    emit(AdminPersonListLoading());
    try {
      List<Person> persons = await personService.getAllPersons();
      emit(AdminPersonListLoaded(persons));
    } catch (e) {
      emit(AdminPersonListError(e.toString()));
    }
  }
}

@immutable
abstract class AdminPersonListState {}

class AdminPersonListInitial extends AdminPersonListState {}

class AdminPersonListLoading extends AdminPersonListState {}

class AdminPersonListLoaded extends AdminPersonListState {
  AdminPersonListLoaded(this.persons);

  final List<Person> persons;
}

class AdminPersonListError extends AdminPersonListState {
  AdminPersonListError(this.error);

  final String error;
}

//TODO: add also states for the search, edit, delete, and add operations
