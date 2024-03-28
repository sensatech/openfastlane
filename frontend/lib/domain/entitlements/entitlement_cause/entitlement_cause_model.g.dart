// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_cause_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntitlementCause _$EntitlementCauseFromJson(Map<String, dynamic> json) => EntitlementCause(
      json['id'] as String,
      json['name'] as String?,
      json['campaignId'] as String,
      (json['criterias'] as List<dynamic>).map((e) => EntitlementCriteria.fromJson(e as Map<String, dynamic>)).toList(),
    );

Map<String, dynamic> _$EntitlementCauseToJson(EntitlementCause instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'campaignId': instance.campaignId,
      'criterias': instance.criterias.map((e) => e.toJson()).toList(),
    };
