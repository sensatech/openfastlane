import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entitlements/consumption/consumption.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_api.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_service.dart';

class ScannerPersonViewModel extends Cubit<ScannerPersonViewState> {
  ScannerPersonViewModel(this._service, this.consumptionApi) : super(ScannerPersonInitial());

  final PersonsService _service;
  final ConsumptionApi consumptionApi;

  Future<void> prepare({
    required String personId,
  }) async {
    try {
      final person = await _service.getSinglePerson(personId);
      emit(ScannerPersonLoaded(person: person!));
      try {
        final consumptions = await consumptionApi.findConsumptions(personId: personId);
        emit(ScannerPersonLoaded(person: person, consumptions: consumptions));
        return;
      } catch (e) {
        emit(ScannerPersonNotFound(error: e.toString()));
      }
    } catch (e) {
      emit(ScannerPersonNotFound(error: e.toString()));
      return;
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
  ScannerPersonLoaded({required this.person, this.consumptions});

  final Person person;
  final List<Consumption>? consumptions;
}
