import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_possibility_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'consumption_possibility.g.dart';

@JsonSerializable(explicitToJson: true)
class ConsumptionPossibility extends Equatable {
  @JsonKey(name: 'status', fromJson: ConsumptionPossibilityType.fromJson)
  final ConsumptionPossibilityType status;

  @JsonKey(name: 'lastConsumptionAt')
  final DateTime? lastConsumptionAt;

  const ConsumptionPossibility({
    required this.status,
    this.lastConsumptionAt,
  });

  factory ConsumptionPossibility.fromJson(Map<String, dynamic> json) => _$ConsumptionPossibilityFromJson(json);
  Map<String, dynamic> toJson() => _$ConsumptionPossibilityToJson(this);

  @override
  List<Object?> get props => [
        status,
        lastConsumptionAt,
      ];
}
