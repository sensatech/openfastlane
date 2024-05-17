// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consumption_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConsumptionInfo _$ConsumptionInfoFromJson(Map<String, dynamic> json) => ConsumptionInfo(
      id: json['id'] as String,
      personId: json['personId'] as String,
      entitlementId: json['entitlementId'] as String,
      entitlementCauseId: json['entitlementCauseId'] as String,
      campaignId: json['campaignId'] as String,
      consumedAt: DateTime.parse(json['consumedAt'] as String),
    );

Map<String, dynamic> _$ConsumptionInfoToJson(ConsumptionInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'personId': instance.personId,
      'entitlementId': instance.entitlementId,
      'entitlementCauseId': instance.entitlementCauseId,
      'campaignId': instance.campaignId,
      'consumedAt': instance.consumedAt.toIso8601String(),
    };
