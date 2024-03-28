// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_criteria_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntitlementCriteria _$EntitlementCriteriaFromJson(Map<String, dynamic> json) =>
    EntitlementCriteria(
      json['id'] as String,
      json['name'] as String,
      EntitlementCriteriaType.fromJson(json['type'] as String),
      (json['options'] as List<dynamic>?)
          ?.map((e) =>
              EntitlementCriteriaOption.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EntitlementCriteriaToJson(
        EntitlementCriteria instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': EntitlementCriteriaType.toJson(instance.type),
      'options': instance.options?.map((e) => e.toJson()).toList(),
    };
