import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entitlement_criteria_model.g.dart';

@JsonSerializable(explicitToJson: true)
class EntitlementCriteria extends Equatable {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'type', fromJson: EntitlementCriteriaType.fromJson, toJson: EntitlementCriteriaType.toJson)
  final EntitlementCriteriaType type;

  const EntitlementCriteria(this.id, this.name, this.type);

  factory EntitlementCriteria.fromJson(Map<String, dynamic> json) => _$EntitlementCriteriaFromJson(json);

  Map<String, dynamic> toJson() => _$EntitlementCriteriaToJson(this);

  @override
  List<Object?> get props => [id, name, type];
}

enum EntitlementCriteriaType {
  text,
  checkbox,
  options,
  integer,
  float;

  static EntitlementCriteriaType fromJson(String value) {
    switch (value) {
      case 'TEXT':
        return EntitlementCriteriaType.text;
      case 'CHECKBOX':
        return EntitlementCriteriaType.checkbox;
      case 'OPTIONS':
        return EntitlementCriteriaType.options;
      case 'INTEGER':
        return EntitlementCriteriaType.integer;
      case 'FLOAT':
        return EntitlementCriteriaType.float;
      default:
        throw Exception('Unknown entitlement criteria type: $value');
    }
  }

  static String toJson(EntitlementCriteriaType value) {
    switch (value) {
      case EntitlementCriteriaType.text:
        return 'TEXT';
      case EntitlementCriteriaType.checkbox:
        return 'CHECKBOX';
      case EntitlementCriteriaType.options:
        return 'OPTIONS';
      case EntitlementCriteriaType.integer:
        return 'INTEGER';
      case EntitlementCriteriaType.float:
        return 'FLOAT';
    }
  }
}
