import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'entitlement_criteria_type.dart';

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

