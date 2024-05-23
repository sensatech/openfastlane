import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/entitlements/entitlement_criteria/entitlement_criteria_type.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/entitlements/create_edit/currency_input_formatter.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entitlement_value.g.dart';

@JsonSerializable(explicitToJson: true)
class EntitlementValue extends Equatable {
  @JsonKey(name: 'criteriaId')
  final String criteriaId;

  @JsonKey(name: 'type', fromJson: EntitlementCriteriaType.fromJson, toJson: EntitlementCriteriaType.toJson)
  final EntitlementCriteriaType type;

  @JsonKey(name: 'value')
  final String value;

  const EntitlementValue({
    required this.criteriaId,
    required this.type,
    required this.value,
  });

  factory EntitlementValue.fromJson(Map<String, dynamic> json) => _$EntitlementValueFromJson(json);

  Map<String, dynamic> toJson() => _$EntitlementValueToJson(this);

  @override
  List<Object?> get props => [criteriaId, type, value];
}

extension EntitlementValueExtension on EntitlementValue {
  dynamic get typeValue {
    try {
      dynamic typeValue = value;
      if (value == 'null' || value == '') {
        typeValue = null;
      }
      switch (type) {
        case EntitlementCriteriaType.text:
          typeValue = typeValue ?? '';
        case EntitlementCriteriaType.checkbox:
          typeValue = typeValue == 'true' ? true : false;
        case EntitlementCriteriaType.float:
          typeValue = double.parse(typeValue ?? '0.0');
        case EntitlementCriteriaType.currency:
          typeValue = double.parse(typeValue ?? '0.0');
        case EntitlementCriteriaType.integer:
          typeValue = int.parse(typeValue ?? '0');
        case EntitlementCriteriaType.options:
          typeValue = typeValue ?? '';
        default:
          typeValue = '';
      }
      return typeValue;
    } catch (e) {
      logger.e('Error in EntitlementValueExtension. Could not get typeValue: $e');
      return null;
    }
  }
}

String? getDisplayValue(BuildContext context, EntitlementValue value) {
  CurrencyInputFormatter formatter = sl<CurrencyInputFormatter>();
  AppLocalizations lang = AppLocalizations.of(context)!;

  try {
    String? displayValue = value.value;
    if (displayValue == 'null' || displayValue == '') {
      displayValue = null;
    }
    switch (value.type) {
      case EntitlementCriteriaType.text:
        displayValue = displayValue ?? '';
      case EntitlementCriteriaType.checkbox:
        displayValue = displayValue == 'true' ? lang.accepted : lang.not_accepted;
      case EntitlementCriteriaType.float:
        double doubleValue = double.parse(displayValue ?? '0.0');
        displayValue = formatter.formatInitialValue(doubleValue);
      case EntitlementCriteriaType.currency:
        double doubleValue = double.parse(displayValue ?? '0.0');
        displayValue = formatter.formatInitialValue(doubleValue);
      case EntitlementCriteriaType.integer:
        displayValue = (displayValue == '') ? '0' : displayValue ?? '0';
      case EntitlementCriteriaType.options:
        displayValue = displayValue ?? '';
      default:
        displayValue = '';
    }
    return displayValue;
  } catch (e) {
    logger.e('Error in getDisplayValue. Could not get displayValue: $e');
    return null;
  }
}
