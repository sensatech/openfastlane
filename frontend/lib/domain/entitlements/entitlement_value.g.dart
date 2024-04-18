// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entitlement_value.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntitlementValue _$EntitlementValueFromJson(Map<String, dynamic> json) =>
    EntitlementValue(
      criteriaId: json['criteriaId'] as String,
      type: EntitlementCriteriaType.fromJson(json['type'] as String),
      value: json['value'] as String,
    );

Map<String, dynamic> _$EntitlementValueToJson(EntitlementValue instance) =>
    <String, dynamic>{
      'criteriaId': instance.criteriaId,
      'type': EntitlementCriteriaType.toJson(instance.type),
      'value': instance.value,
    };
