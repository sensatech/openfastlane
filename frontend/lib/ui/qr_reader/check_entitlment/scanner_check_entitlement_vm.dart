import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlements_api.dart';

class ScannerCheckEntitlementViewModel extends Cubit<ScannerEntitlementViewState> {
  ScannerCheckEntitlementViewModel(this._api) : super(ScannerEntitlementInitial(readOnly: true));

  final EntitlementsApi _api;

  Future<void> prepare({
    required bool readOnly,
    String? entitlementId,
    String? qrCode,
  }) async {
    try {
      emit(ScannerEntitlementLoaded(
          entitlement: const Entitlement(
            id: 'id',
            entitlementCauseId: 'entitlementCauseId',
            personId: 'personId',
            values: [],
          ),
          readOnly: readOnly));
      return;
      if (entitlementId != null) {
        final Entitlement entitlement = await _api.getEntitlement(entitlementId);
        emit(ScannerEntitlementLoaded(entitlement: entitlement, readOnly: readOnly));
        return;
      } else if (qrCode != null) {
        final Entitlement entitlement = await _api.getEntitlement(qrCode);
        emit(ScannerEntitlementLoaded(entitlement: entitlement, readOnly: readOnly));
        return;
      } else {
        emit(ScannerEntitlementNotFound(error: 'No entitlementId or qrCode provided', readOnly: readOnly));
      }
    } catch (e) {
      emit(ScannerEntitlementNotFound(error: e.toString(), readOnly: readOnly));
    }
  }

  Future<void> consume() async {
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
  ScannerEntitlementLoaded({required this.entitlement, required super.readOnly});

  final Entitlement entitlement;
}
