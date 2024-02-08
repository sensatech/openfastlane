// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Person _$PersonFromJson(Map<String, dynamic> json) => Person(
      json['id'] as String,
      json['firstName'] as String,
      json['lastName'] as String,
      DateTime.parse(json['dateOfBirth'] as String),
      $enumDecodeNullable(_$GenderEnumMap, json['gender']),
      Address.fromJson(json['address'] as Map<String, dynamic>),
      json['email'] as String,
      json['mobileNumber'] as String,
      json['comment'] as String,
      DateTime.parse(json['createdAt'] as String),
      DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PersonToJson(Person instance) => <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'gender': _$GenderEnumMap[instance.gender],
      'address': instance.address.toJson(),
      'email': instance.email,
      'mobileNumber': instance.mobileNumber,
      'comment': instance.comment,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.diverse: 'diverse',
};
