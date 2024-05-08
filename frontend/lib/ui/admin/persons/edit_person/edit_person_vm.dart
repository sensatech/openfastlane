import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_service.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class EditOrCreatePersonViewModel extends Cubit<EditPersonState> {
  EditOrCreatePersonViewModel(this._personsService) : super(EditPersonInitial());

  final PersonsService _personsService;

  Logger logger = getLogger();

  late Person _person;

  Future<void> prepare(String personId) async {
    emit(EditPersonLoading());
    try {
      Person? person = await _personsService.getSinglePerson(personId);
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
      Person person = await _personsService.updatePerson(
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
      logger.i('Person updated: $person');
      emit(EditPersonLoaded(person));
      _personsService.invalidateCache();
      // show success message for 1500 milliseconds
      await Future.delayed(const Duration(milliseconds: 1500));
      emit(EditPersonComplete(person.id));
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
      Person person = await _personsService.createPerson(
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
      logger.i('Person created: $person');
      emit(EditPersonLoaded(person));
      _personsService.invalidateCache();
      // show success message for 1500 milliseconds
      await Future.delayed(const Duration(milliseconds: 1500));
      emit(EditPersonComplete(person.id));
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

class EditPersonComplete extends EditPersonState {
  final String personId;

  EditPersonComplete(this.personId);
}
