// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Entitlement _$EntitlementFromJson(Map<String, dynamic> json) => Entitlement(
      id: json['id'] as String,
      entitlementCauseId: json['entitlementCauseId'] as String,
      personId: json['personId'] as String,
      values:
          (json['values'] as List<dynamic>).map((e) => EntitlementValue.fromJson(e as Map<String, dynamic>)).toList(),
      entitlementCause: json['entitlementCause'] == null
          ? null
          : EntitlementCause.fromJson(json['entitlementCause'] as Map<String, dynamic>),
      person: json['person'] == null ? null : Person.fromJson(json['person'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EntitlementToJson(Entitlement instance) => <String, dynamic>{
      'id': instance.id,
      'entitlementCauseId': instance.entitlementCauseId,
      'personId': instance.personId,
      'values': instance.values.map((e) => e.toJson()).toList(),
      'entitlementCause': instance.entitlementCause?.toJson(),
      'person': instance.person?.toJson(),
    };
