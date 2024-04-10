import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entitlements/consumption/consumption.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_api.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_possibility.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlements_service.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class ScannerCheckEntitlementViewModel extends Cubit<ScannerEntitlementViewState> {
  ScannerCheckEntitlementViewModel(this._service, this.consumptionApi)
      : super(ScannerEntitlementInitial(readOnly: true));

  final EntitlementsService _service;
  final ConsumptionApi consumptionApi;

  Logger logger = getLogger();

  Future<void> prepare({
    required bool readOnly,
    String? entitlementId,
    String? qrCode,
  }) async {
    try {
      logger.i('prepare: entitlementId=$entitlementId qrCode=$qrCode readOnly=$readOnly');
      if (qrCode != null) {
        final Entitlement entitlement = await _service.getEntitlement(qrCode, full: true);
        // http://localhost:9080/#/admin/scanner/entitlements/65cb6c1851090750eeee0001
        logger.i('prepare: entitlement=$entitlement');
        emit(ScannerEntitlementLoaded(entitlement: entitlement, readOnly: readOnly));
      } else if (entitlementId != null) {
        final Entitlement entitlement = await _service.getEntitlement(entitlementId, full: true);
        emit(ScannerEntitlementLoaded(entitlement: entitlement, readOnly: readOnly));
      } else {
        emit(ScannerEntitlementNotFound(error: 'No entitlementId or qrCode provided', readOnly: readOnly));
        return;
      }
      await checkConsumptions();
    } catch (e) {
      logger.e('prepare: error=$e', error: e);
      emit(ScannerEntitlementNotFound(error: e.toString(), readOnly: readOnly));
    }
  }

  Future<void> checkConsumptions() async {
    if (state is ScannerEntitlementLoaded) {
      try {
        final entitlement = (state as ScannerEntitlementLoaded).entitlement;
        final consumptions = await consumptionApi.getEntitlementConsumptions(entitlement.id);
        final consumptionPossibility = await consumptionApi.canConsume(entitlement.id);
        logger.e('checkConsumptions: loaded consumptionPossibility=$consumptionPossibility consumptions=$consumptions');
        emit(ScannerEntitlementLoaded(
          entitlement: entitlement,
          consumptions: consumptions,
          consumptionPossibility: consumptionPossibility,
          readOnly: state.readOnly,
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
          logger.e('consume: loaded performConsume=$performConsume');
        } catch (e) {
          logger.e('consume: error=$e', error: e);
          error = e.toString();
        }

        final consumptions = await consumptionApi.getEntitlementConsumptions(entitlement.id);
        final consumptionPossibility = await consumptionApi.canConsume(entitlement.id);
        logger.e(
            'consume: loaded performConsume=$performConsume consumptionPossibility=$consumptionPossibility consumptions=$consumptions');
        emit(ScannerEntitlementLoaded(
          entitlement: entitlement,
          consumptions: consumptions,
          consumptionPossibility: consumptionPossibility,
          readOnly: true,
          error: error,
        ));
      } catch (e) {
        logger.e('consume: error=$e', error: e);
        emit(ScannerEntitlementLoaded(
          entitlement: state.entitlement,
          consumptions: state.consumptions,
          consumptionPossibility: state.consumptionPossibility,
          readOnly: true,
          error: e.toString(),
        ));
      }
    }
    // wait for 1 s
    await Future.delayed(const Duration(seconds: 1));
    emit(ScannerEntitlementLoaded(
        entitlement: const Entitlement(
          id: 'id',
          entitlementCauseId: 'entitlementCauseId',
          personId: 'personId',
          values: [],
        ),
        readOnly: true));
  }
}

class ScannerEntitlementViewState {
  final bool readOnly;

  ScannerEntitlementViewState({required this.readOnly});
}

class ScannerEntitlementInitial extends ScannerEntitlementViewState {
  ScannerEntitlementInitial({required super.readOnly});
}

class ScannerEntitlementNotFound extends ScannerEntitlementViewState {
  ScannerEntitlementNotFound({required super.readOnly, required this.error});

  final String error;
}

class ScannerEntitlementLoaded extends ScannerEntitlementViewState {
  final Entitlement entitlement;
  final List<Consumption>? consumptions;
  final ConsumptionPossibility? consumptionPossibility;

  final String? error;

  ScannerEntitlementLoaded({
    required this.entitlement,
    required super.readOnly,
    this.consumptions,
    this.consumptionPossibility,
    this.error,
  });
}
