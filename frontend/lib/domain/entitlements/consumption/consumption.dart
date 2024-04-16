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

  @JsonKey(name: 'entitlementId')
  final String entitlementId;

  @JsonKey(name: 'entitlementCauseId')
  final String entitlementCauseId;

  @JsonKey(name: 'campaignId')
  final String campaignId;

  @JsonKey(name: 'consumedAt')
  final DateTime consumedAt;

  @JsonKey(name: 'entitlementData')
  final List<EntitlementValue>? entitlementData;

  @JsonKey(name: 'comment')
  final String? comment;

  const Consumption({
    required this.id,
    required this.personId,
    required this.entitlementId,
    required this.entitlementCauseId,
    required this.campaignId,
    required this.consumedAt,
    this.entitlementData,
    this.comment,
  });

  factory Consumption.fromJson(Map<String, dynamic> json) => _$ConsumptionFromJson(json);

  Map<String, dynamic> toJson() => _$ConsumptionToJson(this);

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
