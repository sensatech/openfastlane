import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UiException implements Exception {
  final UiErrorType type;

  UiException(this.type);
}

enum UiErrorType {
  personNotFound,
  entitlementNotFound,
  scannerEntitlementNotFound,
  unknown,
}

extension UiErrorTypeExtension on UiErrorType {
  String toLocale(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;

    switch (this) {
      case UiErrorType.personNotFound:
        return lang.error_personNotFound;
      case UiErrorType.entitlementNotFound:
        return lang.error_entitlementNotFound;
      case UiErrorType.scannerEntitlementNotFound:
        return lang.error_scannerEntitlementNotFound;
      default:
        return lang.error_unknown;
    }
  }
}
