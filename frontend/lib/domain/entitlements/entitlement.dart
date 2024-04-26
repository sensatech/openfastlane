import 'package:equatable/equatable.dart';
import 'package:frontend/domain/audit_item.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/entitlements/entitlement_status.dart';
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
  final DateTime? confirmedAt;

  @JsonKey(name: 'expiresAt')
  final DateTime? expiresAt;

  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;

  @JsonKey(name: 'updatedAt')
  final DateTime? updatedAt;

  @JsonKey(name: 'audit')
  final List<AuditItem> audit;

  @JsonKey(name: 'status', fromJson: EntitlementStatus.fromJson, toJson: EntitlementStatus.toJson)
  final EntitlementStatus status;

  final EntitlementCause? entitlementCause;
  final Person? person;
  final Campaign? campaign;

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
    required this.audit,
    this.entitlementCause,
    required this.status,
    this.person,
    this.campaign,
  });

  factory Entitlement.fromJson(Map<String, dynamic> json) => _$EntitlementFromJson(json);

  Map<String, dynamic> toJson() => _$EntitlementToJson(this);

  @override
  List<Object?> get props => [
        id,
        personId,
        campaignId,
        entitlementCauseId,
        values,
        confirmedAt,
        expiresAt,
        createdAt,
        updatedAt,
        audit,
        status,
        person,
        entitlementCause,
        campaign,
      ];

  Entitlement copyWith({Person? person, EntitlementCause? entitlementCause, Campaign? campaign}) {
    return Entitlement(
      id: id,
      personId: personId,
      campaignId: campaignId,
      entitlementCauseId: entitlementCauseId,
      values: values,
      confirmedAt: confirmedAt,
      expiresAt: expiresAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      audit: audit,
      status: status,
      person: person ?? this.person,
      entitlementCause: entitlementCause ?? this.entitlementCause,
      campaign: campaign ?? this.campaign,
    );
  }
}
