import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/person/persons_service.dart';

class AdminPersonListViewModel extends Cubit<AdminPersonListState> {
  AdminPersonListViewModel(this._personService) : super(AdminPersonListInitial());

  final PersonsService _personService;

  Future<void> loadAllPersons() async {
    emit(AdminPersonListLoading());
    try {
      List<PersonWithEntitlementsInfo> personWithEntitlementsInfo = await _personService.getAllPersonsWithInfo();
      emit(AdminPersonListLoaded(personWithEntitlementsInfo));
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
  AdminPersonListLoaded(this.personsWithEntitlementsInfo);

  final List<PersonWithEntitlementsInfo> personsWithEntitlementsInfo;

  @override
  List<Object> get props => [personsWithEntitlementsInfo];
}

class AdminPersonListError extends AdminPersonListState {
  AdminPersonListError(this.error);

  final String error;

  @override
  List<Object> get props => [error];
}
