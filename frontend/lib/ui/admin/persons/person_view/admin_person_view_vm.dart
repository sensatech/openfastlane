import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/audit_item.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_service.dart';

class AdminPersonViewViewModel extends Cubit<AdminPersonViewState> {
  AdminPersonViewViewModel(this._personService) : super(PersonViewInitial());

  final PersonsService _personService;

  Future<void> loadPerson(String personId) async {
    emit(PersonViewLoading());
    try {
      Person? person = await _personService.getSinglePerson(personId);
      if (person == null) {
        emit(PersonViewError('PersonViewViewModel: Person not found'));
        return;
      }
      final List<Entitlement>? entitlements = await _personService.getPersonEntitlements(personId);
      final List<AuditItem>? history = await _personService.getPersonHistory(personId);

      emit(PersonViewLoaded(person, entitlements: entitlements, history: history));
    } catch (e) {
      emit(PersonViewError(e.toString()));
    }
  }
}

class AdminPersonViewState {}

class PersonViewInitial extends AdminPersonViewState {}

class PersonViewLoading extends AdminPersonViewState {}

class PersonViewLoaded extends AdminPersonViewState {
  PersonViewLoaded(this.person, {this.entitlements, this.history});

  final Person person;
  final List<Entitlement>? entitlements;
  final List<AuditItem>? history;
}

class PersonViewError extends AdminPersonViewState {
  PersonViewError(this.error);

  final String error;
}
