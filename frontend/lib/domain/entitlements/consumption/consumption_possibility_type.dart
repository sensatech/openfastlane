import 'package:flutter/widgets.dart';

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
    // AppLocalizations lang = AppLocalizations.of(context)!;
    switch (this) {
      // todo
      default:
        return toString();
    }
  }
}
