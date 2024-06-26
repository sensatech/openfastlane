import 'package:json_annotation/json_annotation.dart';

part 'rest_exception.g.dart';

@JsonSerializable()
class RestException {
  final String errorName;
  final String errorMessage;
  final DateTime time;

  RestException(this.errorName, this.errorMessage, this.time);

  static const fromJson = _$RestExceptionFromJson;

  Map<String, dynamic> toJson() => _$RestExceptionToJson(this);
}
