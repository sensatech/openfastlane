import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_service.dart';

class AddressDuplicatesBloc extends Bloc<AddressDuplicatesEvent, AddressDuplicatesState> {
  final PersonsService _personService;

  AddressDuplicatesBloc(this._personService) : super(AddressDuplicatesInitial()) {
    on<SearchAddressDuplicateEvent>(
      (event, emit) async {
        emit(AddressDuplicatesLoading());
        try {
          List<Person> duplicatePersons = await _personService.getSimilarAddresses(
              addressId: event.addressId, streetNameNumber: event.streetNameNumber, addressSuffix: event.addressSuffix);
          emit(AddressDuplicatesLoaded(duplicatePersons));
        } catch (e) {
          emit(AddressDuplicatesError(e.toString()));
        }
      },
      transformer: restartable(),
    );
  }
}

@immutable
abstract class AddressDuplicatesEvent {}

class SearchAddressDuplicateEvent extends AddressDuplicatesEvent {
  final String? addressId;
  final String? addressSuffix;
  final String? streetNameNumber;

  SearchAddressDuplicateEvent({this.addressId, this.addressSuffix, this.streetNameNumber});
}

class InitEvent extends AddressDuplicatesEvent {}

@immutable
abstract class AddressDuplicatesState {}

class AddressDuplicatesInitial extends AddressDuplicatesState {}

class AddressDuplicatesLoading extends AddressDuplicatesState {}

class AddressDuplicatesLoaded extends AddressDuplicatesState {
  AddressDuplicatesLoaded(this.duplicates);

  final List<Person> duplicates;
}

class AddressDuplicatesError extends AddressDuplicatesState {
  AddressDuplicatesError(this.error);

  final String error;
}
