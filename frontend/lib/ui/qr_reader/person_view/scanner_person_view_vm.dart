import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_service.dart';

class ScannerPersonViewModel extends Cubit<ScannerPersonViewState> {
  ScannerPersonViewModel(this._service) : super(ScannerPersonInitial());

  final PersonsService _service;

  Future<void> prepare({
    required String personId,
  }) async {
    try {
      final person = await _service.getSinglePerson(personId);
      emit(ScannerPersonLoaded(person: person!));
      return;
    } catch (e) {
      emit(ScannerPersonNotFound(error: e.toString()));
    }
  }
}

class ScannerPersonViewState {
  ScannerPersonViewState();
}

class ScannerPersonInitial extends ScannerPersonViewState {
  ScannerPersonInitial();
}

class ScannerPersonNotFound extends ScannerPersonViewState {
  ScannerPersonNotFound({required this.error});

  final String error;
}

class ScannerPersonLoaded extends ScannerPersonViewState {
  ScannerPersonLoaded({required this.person});

  final Person person;
}
