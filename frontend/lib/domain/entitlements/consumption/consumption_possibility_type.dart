import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum ConsumptionPossibilityType {
  REQUEST_INVALID,
  ENTITLEMENT_INVALID,
  ENTITLEMENT_EXPIRED,
  CONSUMPTION_ALREADY_DONE,
  CONSUMPTION_POSSIBLE,
  UNKNOWN;

  static ConsumptionPossibilityType fromJson(String value) {
    switch (value) {
      case 'REQUEST_INVALID':
        return ConsumptionPossibilityType.REQUEST_INVALID;
      case 'ENTITLEMENT_INVALID':
        return ConsumptionPossibilityType.ENTITLEMENT_INVALID;
      case 'ENTITLEMENT_EXPIRED':
        return ConsumptionPossibilityType.ENTITLEMENT_EXPIRED;
      case 'CONSUMPTION_ALREADY_DONE':
        return ConsumptionPossibilityType.CONSUMPTION_ALREADY_DONE;
      case 'CONSUMPTION_POSSIBLE':
        return ConsumptionPossibilityType.CONSUMPTION_POSSIBLE;
      default:
        return ConsumptionPossibilityType.UNKNOWN;
    }
  }
}

extension ConsumptionPossibilityExtension on ConsumptionPossibilityType {
  String toLocale(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    switch (this) {
      // todo
      default:
        return toString();
    }
  }
}
