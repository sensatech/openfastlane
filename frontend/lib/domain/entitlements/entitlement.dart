import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entitlements/entitlement_value.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entitlement.g.dart';

@JsonSerializable(explicitToJson: true)
class Entitlement extends Equatable {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'entitlementCauseId')
  final String entitlementCauseId;

  @JsonKey(name: 'personId')
  final String personId;

  @JsonKey(name: 'values')
  final List<EntitlementValue> values;

  const Entitlement({
    required this.id,
    required this.entitlementCauseId,
    required this.personId,
    required this.values,
  });

  factory Entitlement.fromJson(Map<String, dynamic> json) => _$EntitlementFromJson(json);

  Map<String, dynamic> toJson() => _$EntitlementToJson(this);

  @override
  List<Object?> get props => [id, entitlementCauseId, personId, values];
}
