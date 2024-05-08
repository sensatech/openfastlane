// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Entitlement _$EntitlementFromJson(Map<String, dynamic> json) => Entitlement(
      id: json['id'] as String,
      entitlementCauseId: json['entitlementCauseId'] as String,
      personId: json['personId'] as String,
      values: (json['values'] as List<dynamic>)
          .map((e) => EntitlementValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      campaignId: json['campaignId'] as String,
      confirmedAt: json['confirmedAt'] == null
          ? null
          : DateTime.parse(json['confirmedAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      audit: (json['audit'] as List<dynamic>)
          .map((e) => AuditItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      entitlementCause: json['entitlementCause'] == null
          ? null
          : EntitlementCause.fromJson(
              json['entitlementCause'] as Map<String, dynamic>),
      status: EntitlementStatus.fromJson(json['status'] as String),
      person: json['person'] == null
          ? null
          : Person.fromJson(json['person'] as Map<String, dynamic>),
      campaign: json['campaign'] == null
          ? null
          : Campaign.fromJson(json['campaign'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EntitlementToJson(Entitlement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'campaignId': instance.campaignId,
      'entitlementCauseId': instance.entitlementCauseId,
      'personId': instance.personId,
      'values': instance.values.map((e) => e.toJson()).toList(),
      'confirmedAt': instance.confirmedAt?.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'audit': instance.audit.map((e) => e.toJson()).toList(),
      'status': EntitlementStatus.toJson(instance.status),
      'entitlementCause': instance.entitlementCause?.toJson(),
      'person': instance.person?.toJson(),
      'campaign': instance.campaign?.toJson(),
    };
