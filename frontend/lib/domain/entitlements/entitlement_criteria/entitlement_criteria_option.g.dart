// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_criteria_option.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntitlementCriteriaOption _$EntitlementCriteriaOptionFromJson(
        Map<String, dynamic> json) =>
    EntitlementCriteriaOption(
      json['key'] as String,
      json['label'] as String,
      json['order'] as int,
      json['description'] as String?,
    );

Map<String, dynamic> _$EntitlementCriteriaOptionToJson(
        EntitlementCriteriaOption instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'order': instance.order,
      'description': instance.description,
    };
