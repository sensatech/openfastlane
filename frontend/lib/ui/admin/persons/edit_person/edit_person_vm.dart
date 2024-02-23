import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_service.dart';

class EditPersonViewModel extends Cubit<EditPersonState> {
  EditPersonViewModel(this._personService) : super(EditPersonInitial());

  final PersonsService _personService;

  Future<void> loadPerson(String personId) async {
    emit(EditPersonLoading());
    try {
      Person? person = await _personService.getSinglePerson(personId);
      if (person == null) {
        emit(EditPersonError('EditPersonViewModel: Person not found'));
        return;
      }
      emit(EditPersonLoaded(person));
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
