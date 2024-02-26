import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/person_service.dart';

class AdminPersonViewViewModel extends Cubit<AdminPersonViewState> {
  AdminPersonViewViewModel(this._personService) : super(PersonViewInitial());

  final PersonService _personService;

  Future<void> loadPerson(String personId) async {
    emit(PersonViewLoading());
    try {
      Person? person = await _personService.getSinglePerson(personId);
      if (person == null) {
        emit(PersonViewError('PersonViewViewModel: Person not found'));
        return;
      }
      emit(PersonViewLoaded(person));
    } catch (e) {
      emit(PersonViewError(e.toString()));
    }
  }
}

class AdminPersonViewState {}

class PersonViewInitial extends AdminPersonViewState {}

class PersonViewLoading extends AdminPersonViewState {}

class PersonViewLoaded extends AdminPersonViewState {
  PersonViewLoaded(this.person);

  final Person person;
}

class PersonViewError extends AdminPersonViewState {
  PersonViewError(this.error);

  final String error;
}
