// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consumption_possibility.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConsumptionPossibility _$ConsumptionPossibilityFromJson(
        Map<String, dynamic> json) =>
    ConsumptionPossibility(
      status: $enumDecode(_$ConsumptionPossibilityTypeEnumMap, json['status']),
      lastConsumptionAt: json['lastConsumptionAt'] == null
          ? null
          : DateTime.parse(json['lastConsumptionAt'] as String),
    );

Map<String, dynamic> _$ConsumptionPossibilityToJson(
        ConsumptionPossibility instance) =>
    <String, dynamic>{
      'status': _$ConsumptionPossibilityTypeEnumMap[instance.status]!,
      'lastConsumptionAt': instance.lastConsumptionAt?.toIso8601String(),
    };

const _$ConsumptionPossibilityTypeEnumMap = {
  ConsumptionPossibilityType.requestInvalid: 'requestInvalid',
  ConsumptionPossibilityType.entitlementInvalid: 'entitlementInvalid',
  ConsumptionPossibilityType.entitlementExpired: 'entitlementExpired',
  ConsumptionPossibilityType.consumptionAlreadyDone: 'consumptionAlreadyDone',
  ConsumptionPossibilityType.consumptionPossible: 'consumptionPossible',
  ConsumptionPossibilityType.unknown: 'unknown',
};
