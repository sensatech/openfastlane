import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entitlements/entitlement_criteria/entitlement_criteria_type.dart';
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

//TODO: add toString method for all value types

//TODO: add fromString method for all value types
