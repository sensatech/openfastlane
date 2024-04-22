import 'package:flutter/material.dart';

enum ConsumptionPossibilityType {
  // make them camelcase:

  requestInvalid,
  entitlementInvalid,
  entitlementExpired,
  consumptionAlreadyDone,
  consumptionPossible,
  unknown;

  static ConsumptionPossibilityType fromJson(String value) {
    switch (value) {
      case 'REQUEST_INVALID':
        return ConsumptionPossibilityType.requestInvalid;
      case 'ENTITLEMENT_INVALID':
        return ConsumptionPossibilityType.entitlementInvalid;
      case 'ENTITLEMENT_EXPIRED':
        return ConsumptionPossibilityType.entitlementExpired;
      case 'CONSUMPTION_ALREADY_DONE':
        return ConsumptionPossibilityType.consumptionAlreadyDone;
      case 'CONSUMPTION_POSSIBLE':
        return ConsumptionPossibilityType.consumptionPossible;
      default:
        return ConsumptionPossibilityType.unknown;
    }
  }
}

extension ConsumptionPossibilityExtension on ConsumptionPossibilityType {
  String toLocale(BuildContext context) {
    switch (this) {
      //TODO: add l10n
      case ConsumptionPossibilityType.requestInvalid:
        return 'Anfrage ungültig';
      case ConsumptionPossibilityType.entitlementInvalid:
        return 'Berechtigung ungültig';
      case ConsumptionPossibilityType.entitlementExpired:
        return 'Berechtigung abgelaufen';
      case ConsumptionPossibilityType.consumptionAlreadyDone:
        return 'Bezug bereits vorgenommen';
      case ConsumptionPossibilityType.consumptionPossible:
        return 'Bezug möglich';
      case ConsumptionPossibilityType.unknown:
        return 'Status Unbekannt';
      default:
        return toString();
    }
  }
}

extension ConsumptionPossibilityColorExtension on ConsumptionPossibilityType {
  Color toColor() {
    switch (this) {
      case ConsumptionPossibilityType.consumptionPossible:
        return Colors.green;
      case ConsumptionPossibilityType.consumptionAlreadyDone:
        return Colors.orange;
      case ConsumptionPossibilityType.requestInvalid:
      case ConsumptionPossibilityType.entitlementInvalid:
      case ConsumptionPossibilityType.entitlementExpired:
      case ConsumptionPossibilityType.unknown:
        return Colors.red;
    }
  }
}
