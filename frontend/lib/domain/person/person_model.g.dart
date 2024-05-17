// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Person _$PersonFromJson(Map<String, dynamic> json) => Person(
      json['id'] as String,
      json['firstName'] as String,
      json['lastName'] as String,
      json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      Gender.fromJson(json['gender'] as String?),
      json['address'] == null
          ? null
          : Address.fromJson(json['address'] as Map<String, dynamic>),
      json['email'] as String?,
      json['mobileNumber'] as String?,
      json['comment'] as String,
      (json['similarPersonIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      DateTime.parse(json['createdAt'] as String),
      DateTime.parse(json['updatedAt'] as String),
      (json['entitlements'] as List<dynamic>?)
          ?.map((e) => Entitlement.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['lastConsumptions'] as List<dynamic>?)
          ?.map((e) => ConsumptionInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PersonToJson(Person instance) => <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'gender': Gender.toJson(instance.gender),
      'address': instance.address?.toJson(),
      'email': instance.email,
      'mobileNumber': instance.mobileNumber,
      'comment': instance.comment,
      'similarPersonIds': instance.similarPersonIds,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'entitlements': instance.entitlements?.map((e) => e.toJson()).toList(),
      'lastConsumptions':
          instance.lastConsumptions?.map((e) => e.toJson()).toList(),
    };
