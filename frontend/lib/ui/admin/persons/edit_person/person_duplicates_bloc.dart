import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_service.dart';

// We're using BLoC instead of Cubit in this class because we need to leverage the transformer property of BLoC.
// This ensures that the event is restartable and prevents multiple simultaneous events, crucial for detecting duplicates
// based on dynamic user input. With input changing dynamically with each new letter typed into a text field,
// previous input becomes obsolete.

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
        } on Exception catch (e) {
          emit(PersonDuplicatesError(e));
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

class InitEvent extends PersonDuplicatesEvent {}

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

  final Exception error;
}
