// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuditItem _$AuditItemFromJson(Map<String, dynamic> json) => AuditItem(
      user: json['user'] as String,
      action: json['action'] as String,
      message: json['message'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
    );

Map<String, dynamic> _$AuditItemToJson(AuditItem instance) => <String, dynamic>{
      'user': instance.user,
      'action': instance.action,
      'message': instance.message,
      'dateTime': instance.dateTime.toIso8601String(),
    };
