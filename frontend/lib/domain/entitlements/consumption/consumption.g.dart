// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consumption.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Consumption _$ConsumptionFromJson(Map<String, dynamic> json) => Consumption(
      id: json['id'] as String,
      personId: json['personId'] as String,
      entitlementId: json['entitlementId'] as String,
      entitlementCauseId: json['entitlementCauseId'] as String,
      campaignId: json['campaignId'] as String,
      consumedAt: DateTime.parse(json['consumedAt'] as String),
      entitlementData: (json['entitlementData'] as List<dynamic>?)
          ?.map((e) => EntitlementValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$ConsumptionToJson(Consumption instance) =>
    <String, dynamic>{
      'id': instance.id,
      'personId': instance.personId,
      'entitlementId': instance.entitlementId,
      'entitlementCauseId': instance.entitlementCauseId,
      'campaignId': instance.campaignId,
      'consumedAt': instance.consumedAt.toIso8601String(),
      'entitlementData':
          instance.entitlementData?.map((e) => e.toJson()).toList(),
      'comment': instance.comment,
    };
