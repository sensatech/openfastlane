// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Campaign _$CampaignFromJson(Map<String, dynamic> json) => Campaign(
      json['id'] as String,
      json['name'] as String,
      Period.fromJson(json['period'] as String),
      (json['causes'] as List<dynamic>?)
          ?.map((e) => EntitlementCause.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CampaignToJson(Campaign instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'period': Period.toJson(instance.period),
      'causes': instance.causes?.map((e) => e.toJson()).toList(),
    };
