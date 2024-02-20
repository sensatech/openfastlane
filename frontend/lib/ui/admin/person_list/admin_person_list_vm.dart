import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/person_service.dart';

class AdminPersonListViewModel extends Cubit<AdminPersonListState> {
  AdminPersonListViewModel(this._personService) : super(AdminPersonListInitial());

  final PersonService _personService;

  Future<void> loadAllPersons() async {
    emit(AdminPersonListLoading());
    try {
      List<Person> persons = await _personService.getAllPersons();
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
