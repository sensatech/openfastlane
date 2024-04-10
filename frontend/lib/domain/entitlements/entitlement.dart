import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/entitlements/entitlement_value.dart';
import 'package:json_annotation/json_annotation.dart';

import '../person/person_model.dart';

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

  final EntitlementCause? entitlementCause;

  final Person? person;

  const Entitlement({
    required this.id,
    required this.entitlementCauseId,
    required this.personId,
    required this.values,
    this.entitlementCause,
    this.person,
  });

  factory Entitlement.fromJson(Map<String, dynamic> json) => _$EntitlementFromJson(json);

  Map<String, dynamic> toJson() => _$EntitlementToJson(this);

  @override
  List<Object?> get props => [id, entitlementCauseId, personId, values];

  Entitlement copyWith({Person? person, EntitlementCause? entitlementCause}) {
    return Entitlement(
      id: id,
      entitlementCauseId: entitlementCauseId,
      personId: personId,
      values: values,
      person: person,
      entitlementCause: entitlementCause,
    );
  }
}
