import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entitlements/entitlement_criteria/entitlement_criteria_type.dart';
import 'package:frontend/ui/admin/entitlements/create_edit/currency_input_formatter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entitlement_value.g.dart';

@JsonSerializable(explicitToJson: true)
class EntitlementValue extends Equatable {
  @JsonKey(name: 'criteriaId')
  final String criteriaId;

  @JsonKey(name: 'type', fromJson: EntitlementCriteriaType.fromJson, toJson: EntitlementCriteriaType.toJson)
  final EntitlementCriteriaType type;

  @JsonKey(name: 'value')
  final String? value;

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
    switch (type) {
      case EntitlementCriteriaType.text:
        return value ?? '';
      case EntitlementCriteriaType.checkbox:
        return value == 'true' ? true : false;
      case EntitlementCriteriaType.options:
        return value ?? '';
      case EntitlementCriteriaType.integer:
        return int.parse(value ?? '0');
      case EntitlementCriteriaType.float:
        return double.parse(value ?? '0.0');
      default:
        return '';
    }
  }

  dynamic get displayValue {
    switch (type) {
      case EntitlementCriteriaType.text:
        return value ?? '';
      case EntitlementCriteriaType.checkbox:
        return value == 'true' ? 'bestätigt' : 'nicht bestätigt';
      case EntitlementCriteriaType.options:
        return value;
      case EntitlementCriteriaType.integer:
        return value;
      case EntitlementCriteriaType.float:
        return formatInitialValue(double.parse(value ?? '0.0'));

      default:
        return '';
    }
  }
}
