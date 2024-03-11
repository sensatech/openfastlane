// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rest_exception.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestException _$RestExceptionFromJson(Map<String, dynamic> json) =>
    RestException(
      json['errorCode'] as int,
      json['errorName'] as String,
      json['errorMessage'] as String,
      DateTime.parse(json['time'] as String),
    );

Map<String, dynamic> _$RestExceptionToJson(RestException instance) =>
    <String, dynamic>{
      'errorCode': instance.errorCode,
      'errorName': instance.errorName,
      'errorMessage': instance.errorMessage,
      'time': instance.time.toIso8601String(),
    };
