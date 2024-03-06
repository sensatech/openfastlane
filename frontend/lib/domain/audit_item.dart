import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'audit_item.g.dart';

@JsonSerializable(explicitToJson: true)
class AuditItem extends Equatable {
  @JsonKey(name: 'user')
  final String user;

  @JsonKey(name: 'action')
  final String action;

  @JsonKey(name: 'message')
  final String message;

  @JsonKey(name: 'dateTime')
  final DateTime dateTime;

  const AuditItem({
    required this.user,
    required this.action,
    required this.message,
    required this.dateTime,
  });

  factory AuditItem.fromJson(Map<String, dynamic> json) => _$AuditItemFromJson(json);

  Map<String, dynamic> toJson() => _$AuditItemToJson(this);

  @override
  List<Object?> get props => [user, action, message, dateTime];
}
