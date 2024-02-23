import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_service.dart';

class PersonDuplicatesBloc extends Bloc<PersonDuplicatesEvent, PersonDuplicatesState> {
  final PersonsService _personService;
  PersonDuplicatesBloc(this._personService) : super(PersonDuplicatesInitial()) {
    on<SearchDuplicateEvent>(
      (event, emit) async {
        emit(PersonDuplicatesLoading());
        try {
          List<Person> duplicatePersons =
              await _personService.getSimilarPersons(event.firstName, event.lastName, event.dateOfBirth);
          emit(PersonDuplicatesLoaded(duplicatePersons));
        } catch (e) {
          emit(PersonDuplicatesError(e.toString()));
        }
      },
      transformer: restartable(),
    );
  }
}

@immutable
abstract class PersonDuplicatesEvent {}

class SearchDuplicateEvent extends PersonDuplicatesEvent {
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;

  SearchDuplicateEvent(this.firstName, this.lastName, this.dateOfBirth);
}

@immutable
abstract class PersonDuplicatesState {}

class PersonDuplicatesInitial extends PersonDuplicatesState {}

class PersonDuplicatesLoading extends PersonDuplicatesState {}

class PersonDuplicatesLoaded extends PersonDuplicatesState {
  PersonDuplicatesLoaded(this.duplicates);

  final List<Person> duplicates;
}

class PersonDuplicatesError extends PersonDuplicatesState {
  PersonDuplicatesError(this.error);

  final String error;
}
