import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entitlements/consumption/consumption.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_api.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_possibility.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlements_service.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class ScannerEntitlementViewModel extends Cubit<ScannerEntitlementViewState> {
  ScannerEntitlementViewModel(this._service, this.consumptionApi) : super(ScannerEntitlementInitial());

  final EntitlementsService _service;
  final ConsumptionApi consumptionApi;

  Logger logger = getLogger();

  Future<void> prepare({
    String? entitlementId,
  }) async {
    try {
      logger.i('prepare: entitlementId=$entitlementId');
      if (entitlementId != null) {
        final Entitlement entitlement = await _service.getEntitlement(entitlementId, includeNested: true);
        logger.i(
            'url SHOULD:\nhttps://vh-ofl.at/qr/${entitlement.entitlementCauseId}-${entitlement.personId}-${entitlement.id}-epoch');

        emit(ScannerEntitlementLoaded(entitlement: entitlement));
      } else {
        emit(ScannerEntitlementNotFound(error: 'No entitlementId or qrCode provided'));
        return;
      }
      await checkConsumptions();
    } catch (e) {
      logger.e('prepare: error=$e', error: e);
      emit(ScannerEntitlementNotFound(error: e.toString()));
    }
  }

  Future<void> checkConsumptions() async {
    if (state is ScannerEntitlementLoaded) {
      try {
        final entitlement = (state as ScannerEntitlementLoaded).entitlement;
        final consumptions = await consumptionApi.getEntitlementConsumptions(entitlement.id);
        final consumptionPossibility = await consumptionApi.canConsume(entitlement.id);
        logger.i('checkConsumptions: loaded consumptionPossibility=$consumptionPossibility consumptions=$consumptions');
        emit(ScannerEntitlementLoaded(
          entitlement: entitlement,
          consumptions: consumptions,
          consumptionPossibility: consumptionPossibility,
        ));
      } catch (e) {
        logger.e('checkConsumptions: error=$e', error: e);
        emit(state);
      }
    }
  }

  Future<void> consume() async {
    if (state is ScannerEntitlementLoaded) {
      final state = this.state as ScannerEntitlementLoaded;
      final entitlement = state.entitlement;
      try {
        String? error;
        Consumption? performConsume;
        try {
          performConsume = await consumptionApi.performConsume(entitlement.id);
          logger.i('consume: loaded performConsume=$performConsume');
        } catch (e) {
          logger.e('consume: error=$e', error: e);
          error = e.toString();
        }

        final consumptionPossibility = await consumptionApi.canConsume(entitlement.id);
        logger.i('consume: loaded performConsume=$performConsume consumptionPossibility=$consumptionPossibility');
        emit(ScannerEntitlementLoaded(
          entitlement: entitlement,
          consumptions: state.consumptions,
          consumptionPossibility: consumptionPossibility,
          error: error,
        ));
        final consumptions = await consumptionApi.getEntitlementConsumptions(entitlement.id);
        logger.i(
            'consume: loaded performConsume=$performConsume consumptionPossibility=$consumptionPossibility consumptions=$consumptions');
        emit(ScannerEntitlementLoaded(
          entitlement: entitlement,
          consumptions: consumptions,
          consumptionPossibility: consumptionPossibility,
          error: error,
        ));
      } catch (e) {
        logger.e('consume: error=$e', error: e);
        emit(ScannerEntitlementLoaded(
          entitlement: state.entitlement,
          consumptions: state.consumptions,
          consumptionPossibility: state.consumptionPossibility,
          error: e.toString(),
        ));
      }
    }
  }
}

class ScannerEntitlementViewState {
  ScannerEntitlementViewState();
}

class ScannerEntitlementInitial extends ScannerEntitlementViewState {
  ScannerEntitlementInitial();
}

class ScannerEntitlementNotFound extends ScannerEntitlementViewState {
  ScannerEntitlementNotFound({required this.error});

  final String error;
}

class ScannerEntitlementLoaded extends ScannerEntitlementViewState {
  final Entitlement entitlement;
  final List<Consumption>? consumptions;
  final ConsumptionPossibility? consumptionPossibility;

  final String? error;

  ScannerEntitlementLoaded({
    required this.entitlement,
    this.consumptions,
    this.consumptionPossibility,
    this.error,
  });
}
