import 'package:flutter/material.dart';

enum EntitlementStatus {
  pending,
  valid,
  invalid,
  expired,
  unknown;

  static EntitlementStatus fromJson(String value) {
    switch (value) {
      case 'PENDING':
        return EntitlementStatus.pending;
      case 'VALID':
        return EntitlementStatus.valid;
      case 'INVALID':
        return EntitlementStatus.invalid;
      case 'EXPIRED':
        return EntitlementStatus.expired;
      default:
        return EntitlementStatus.unknown;
    }
  }

  static String toJson(EntitlementStatus value) {
    switch (value) {
      case EntitlementStatus.pending:
        return 'PENDING';
      case EntitlementStatus.valid:
        return 'VALID';
      case EntitlementStatus.invalid:
        return 'INVALID';
      case EntitlementStatus.expired:
        return 'EXPIRED';
      default:
        return 'UNKNOWN';
    }
  }
}

extension EntitlementStatusExtension on EntitlementStatus {
  //TODO: add locale
  String toLocale(BuildContext context) {
    switch (this) {
      case EntitlementStatus.pending:
        return 'Ausstehend';
      case EntitlementStatus.valid:
        return 'Gültig';
      case EntitlementStatus.invalid:
        return 'Ungültig';
      case EntitlementStatus.expired:
        return 'Abgelaufen';
      case EntitlementStatus.unknown:
        return 'Status Unbekannt';
      default:
        return toString();
    }
  }
}

extension EntitlementStatusColorExtension on EntitlementStatus {
  Color toColor() {
    switch (this) {
      case EntitlementStatus.valid:
        return Colors.green;
      case EntitlementStatus.invalid:
      case EntitlementStatus.expired:
        return Colors.red;
      case EntitlementStatus.pending:
      case EntitlementStatus.unknown:
        return Colors.orange;
      default:
        return Colors.black;
    }
  }
}
