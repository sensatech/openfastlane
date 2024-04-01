import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/person/address/address_model.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_api.dart';

class ScannerPersonViewModel extends Cubit<ScannerPersonViewState> {
  ScannerPersonViewModel(this._api) : super(ScannerPersonInitial());

  final PersonsApi _api;

  Future<void> prepare({
    String? personId,
  }) async {
    try {
      emit(ScannerPersonLoaded(
        person: Person(
          'id123123123',
          'Maxi',
          'McMustermann',
          DateTime.now(),
          Gender.male,
          const Address('Musterstraße 123', '4', '1020', null, null),
          'mail@mailgasse.com',
          '0565 45 74 780',
          'EIn sehr langes Kommentar.\n Die Person kommt oft zu spät und ist sehr unzuverlässig.'
              'Sie hat auch schon mehrmals versucht, sich als jemand anderes auszugeben.',
          const ['id123123'],
          DateTime.now(),
          DateTime.now(),
        ),
      ));
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
