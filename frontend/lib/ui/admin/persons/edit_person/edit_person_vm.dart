import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_service.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class EditPersonViewModel extends Cubit<EditPersonState> {
  EditPersonViewModel(this._personService) : super(EditPersonInitial());

  final PersonsService _personService;

  Logger logger = getLogger();

  late Person _person;

  Future<void> prepare(String personId) async {
    emit(EditPersonLoading());
    try {
      Person? person = await _personService.getSinglePerson(personId);
      if (person == null) {
        emit(EditPersonError('EditPersonViewModel: Person not found'));
        return;
      }
      _person = person;
      emit(EditPersonLoaded(person));
    } catch (e) {
      emit(EditPersonError(e.toString()));
    }
  }

  Future<void> editPerson({
    String? firstName,
    String? lastName,
    Gender? gender,
    DateTime? dateOfBirth,
    String? streetNameNumber,
    String? addressSuffix,
    String? postalCode,
    String? email,
    String? mobileNumber,
    String? comment,
  }) async {
    try {
      final result = await _personService.updatePerson(
        _person.id,
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        gender: gender,
        streetNameNumber: streetNameNumber,
        addressSuffix: addressSuffix,
        postalCode: postalCode,
        email: email,
        mobileNumber: mobileNumber,
        comment: comment,
      );
      logger.i('Person updated: $result');
      emit(EditPersonLoaded(result));
      _personService.invalidateCache();
      await Future.delayed(const Duration(milliseconds: 1500));
      emit(EditPersonComplete());
    } catch (e) {
      logger.e('Error while updating person: $e');
      emit(EditPersonError(e.toString()));
    }
  }

  Future<void> createPerson({
    required String firstName,
    required String lastName,
    required Gender gender,
    required DateTime dateOfBirth,
    required String streetNameNumber,
    required String addressSuffix,
    required String postalCode,
    String? email,
    String? mobileNumber,
    String? comment,
  }) async {
    try {
      final result = await _personService.createPerson(
          firstName: firstName,
          lastName: lastName,
          gender: gender,
          dateOfBirth: dateOfBirth,
          streetNameNumber: streetNameNumber,
          addressSuffix: addressSuffix,
          postalCode: postalCode,
          email: email,
          mobileNumber: mobileNumber,
          comment: comment);
      logger.i('Person created: $result');
      emit(EditPersonLoaded(result));
      _personService.invalidateCache();
      await Future.delayed(const Duration(milliseconds: 1500));
      emit(EditPersonComplete());
    } catch (e) {
      logger.e('Error while creating person: $e');
      emit(EditPersonError(e.toString()));
    }
  }
}

class EditPersonState {}

class EditPersonInitial extends EditPersonState {}

class EditPersonLoading extends EditPersonState {}

class EditPersonLoaded extends EditPersonState {
  EditPersonLoaded(this.person);

  final Person person;
}

class EditPersonError extends EditPersonState {
  EditPersonError(this.error);

  final String error;
}

class EditPersonComplete extends EditPersonState {}
