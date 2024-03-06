import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_service.dart';

class EditPersonViewModel extends Cubit<EditPersonState> {
  EditPersonViewModel(this._personService) : super(EditPersonInitial());

  final PersonsService _personService;

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

  Future<void> performUpdate({
    String? firstName,
    String? lastName,
    Gender? gender,
    String? dateOfBirth,
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
      emit(EditPersonLoaded(result));
    } catch (e) {
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
