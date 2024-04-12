import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/entitlements/entitlement_value.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entitlement.g.dart';

@JsonSerializable(explicitToJson: true)
class Entitlement extends Equatable {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'campaignId')
  final String campaignId;

  @JsonKey(name: 'entitlementCauseId')
  final String entitlementCauseId;

  @JsonKey(name: 'personId')
  final String personId;

  @JsonKey(name: 'values')
  final List<EntitlementValue> values;

  @JsonKey(name: 'confirmedAt')
  final DateTime confirmedAt;

  @JsonKey(name: 'expiresAt')
  final DateTime? expiresAt;

  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;
  final EntitlementCause? entitlementCause;

  final Person? person;

  const Entitlement({
    required this.id,
    required this.entitlementCauseId,
    required this.personId,
    required this.values,
    required this.campaignId,
    required this.confirmedAt,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.entitlementCause,
    this.person,
  });

  factory Entitlement.fromJson(Map<String, dynamic> json) => _$EntitlementFromJson(json);

  Map<String, dynamic> toJson() => _$EntitlementToJson(this);

  @override
  List<Object?> get props => [id, entitlementCauseId, personId, values];

  Entitlement copyWith({Person? person, EntitlementCause? entitlementCause}) {
    return Entitlement(
      id: id,
      personId: personId,
      campaignId: campaignId,
      entitlementCauseId: entitlementCauseId,
      values: values,
      person: person,
      entitlementCause: entitlementCause,
      confirmedAt: confirmedAt,
      expiresAt: expiresAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
