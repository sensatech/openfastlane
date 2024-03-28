import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entitlement_criteria_option.g.dart';

@JsonSerializable(explicitToJson: true)
class EntitlementCriteriaOption extends Equatable {
  @JsonKey(name: 'key')
  final String key;

  @JsonKey(name: 'label')
  final String label;

  @JsonKey(name: 'order')
  final int order;

  @JsonKey(name: 'description')
  final String? description;

  const EntitlementCriteriaOption(this.key, this.label, this.order, this.description);

  factory EntitlementCriteriaOption.fromJson(Map<String, dynamic> json) => _$EntitlementCriteriaOptionFromJson(json);

  Map<String, dynamic> toJson() => _$EntitlementCriteriaOptionToJson(this);

  @override
  List<Object?> get props => [key, label, order, description];
}
