import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'consumption_possibility_type.dart';

part 'consumption_possibility.g.dart';

@JsonSerializable(explicitToJson: true)
class ConsumptionPossibility extends Equatable {
  @JsonKey(name: 'status')
  final ConsumptionPossibilityType status;

  @JsonKey(name: 'lastConsumptionAt')
  final DateTime? lastConsumptionAt;

  const ConsumptionPossibility({
    required this.status,
    this.lastConsumptionAt,
  });

  factory ConsumptionPossibility.fromJson(Map<String, dynamic> json) => _$ConsumptionPossibilityFromJson(json);

  @override
  List<Object?> get props => [
        status,
        lastConsumptionAt,
      ];
}
