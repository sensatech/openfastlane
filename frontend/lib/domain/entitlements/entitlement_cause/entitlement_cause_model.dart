import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entitlements/entitlement_criteria/entitlement_criteria_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entitlement_cause_model.g.dart';

@JsonSerializable(explicitToJson: true)
class EntitlementCause extends Equatable {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'campaignId')
  final String campaignId;

  @JsonKey(name: 'criterias')
  final List<EntitlementCriteria> criterias;

  const EntitlementCause(this.id, this.name, this.campaignId, this.criterias);

  factory EntitlementCause.fromJson(Map<String, dynamic> json) => _$EntitlementCauseFromJson(json);

  Map<String, dynamic> toJson() => _$EntitlementCauseToJson(this);

  @override
  List<Object?> get props => [id, name, campaignId, criterias];
}
