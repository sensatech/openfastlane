part of 'consumption_possibility.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConsumptionPossibility _$ConsumptionPossibilityFromJson(Map<String, dynamic> json) => ConsumptionPossibility(
      status: ConsumptionPossibilityType.fromJson(json['status'] as String),
      lastConsumptionAt: json['lastConsumptionAt'] == null ? null : DateTime.parse(json['lastConsumptionAt'] as String),
    );
