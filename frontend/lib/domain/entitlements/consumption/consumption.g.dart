// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consumption.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Consumption _$ConsumptionFromJson(Map<String, dynamic> json) => Consumption(
      id: json['id'] as String,
      personId: json['personId'] as String,
      entitlementCauseId: json['entitlementCauseId'] as String,
      campaignId: json['campaignId'] as String,
      consumedAt: DateTime.parse(json['consumedAt'] as String),
      entitlementData: (json['entitlementData'] as List<dynamic>)
          .map((e) => EntitlementValue.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
