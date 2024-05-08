import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entitlements/consumption/consumption.dart';
import 'package:frontend/domain/entitlements/entitlements_service.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_service.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class ScannerPersonViewModel extends Cubit<ScannerPersonViewState> {
  ScannerPersonViewModel(this._personsService, this._entitlementsService) : super(ScannerPersonInitial());

  final PersonsService _personsService;
  final EntitlementsService _entitlementsService;

  final Logger logger = getLogger();

  Future<void> prepare({required String personId, required String campaignId}) async {
    try {
      final person = await _personsService.getSinglePerson(personId);
      emit(ScannerPersonLoaded(person: person!));
      try {
        final List<Consumption> consumptions =
            await _entitlementsService.getConsumptionsWithCampaignName(personId: personId, campaignId: campaignId);
        emit(ScannerPersonLoaded(person: person, consumptions: consumptions));
        return;
      } catch (e) {
        logger.e('prepare: error=$e', error: e);
        emit(ScannerPersonNotFound(error: e.toString()));
      }
    } catch (e) {
      logger.e('prepare: error=$e', error: e);
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
