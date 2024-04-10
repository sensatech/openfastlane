import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entitlements/entitlement_value.dart';
import 'package:json_annotation/json_annotation.dart';

part 'consumption.g.dart';

@JsonSerializable(explicitToJson: true)
class Consumption extends Equatable {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'personId')
  final String personId;

  @JsonKey(name: 'entitlementCauseId')
  final String entitlementCauseId;

  @JsonKey(name: 'campaignId')
  final String campaignId;

  @JsonKey(name: 'consumedAt')
  final DateTime consumedAt;

  @JsonKey(name: 'entitlementData')
  final List<EntitlementValue> entitlementData;

  const Consumption({
    required this.id,
    required this.personId,
    required this.entitlementCauseId,
    required this.campaignId,
    required this.consumedAt,
    required this.entitlementData,
  });

  factory Consumption.fromJson(Map<String, dynamic> json) => _$ConsumptionFromJson(json);

  @override
  List<Object?> get props => [
        id,
        personId,
        entitlementCauseId,
        campaignId,
        consumedAt,
        entitlementData,
      ];
}
