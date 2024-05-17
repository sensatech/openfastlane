import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'consumption_info.g.dart';

@JsonSerializable(explicitToJson: true)
class ConsumptionInfo extends Equatable {
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

  final String? campaignName;

  @JsonKey(name: 'consumedAt')
  final DateTime consumedAt;


  const ConsumptionInfo({
    required this.id,
    required this.personId,
    required this.entitlementId,
    required this.entitlementCauseId,
    required this.campaignId,
    this.campaignName,
    required this.consumedAt,
  });

  factory ConsumptionInfo.fromJson(Map<String, dynamic> json) => _$ConsumptionInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ConsumptionInfoToJson(this);

  @override
  List<Object?> get props => [
        id,
        personId,
        entitlementId,
        entitlementCauseId,
        campaignId,
        consumedAt,
      ];

  }
