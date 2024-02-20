//this is just a sample model - will be implemented soon
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/campaign/entitlement_cause_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'campaign_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Campaign extends Equatable {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'period', fromJson: Period.fromJson, toJson: Period.toJson)
  final Period period;

  @JsonKey(name: 'causes')
  final List<EntitlementCause>? causes;

  const Campaign(this.id, this.name, this.period, this.causes);

  factory Campaign.fromJson(Map<String, dynamic> json) => _$CampaignFromJson(json);

  Map<String, dynamic> toJson() => _$CampaignToJson(this);

  @override
  List<Object?> get props => [id, name, period, causes];
}

enum Period {
  once,
  daily,
  weekly,
  monthly;

  static Period fromJson(String value) {
    switch (value) {
      case 'ONCE':
        return Period.once;
      case 'DAILY':
        return Period.daily;
      case 'WEEKLY':
        return Period.weekly;
      case 'MONTHLY':
        return Period.monthly;
      default:
        throw Exception('Unknown period: $value');
    }
  }

  static String toJson(Period value) {
    switch (value) {
      case Period.once:
        return 'ONCE';
      case Period.daily:
        return 'DAILY';
      case Period.weekly:
        return 'WEEKLY';
      case Period.monthly:
        return 'MONTHLY';
    }
  }
}

extension PeriodExtension on Period {
  String toLocale(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    switch (this) {
      case Period.once:
        return lang.once;
      case Period.daily:
        return lang.daily;
      case Period.weekly:
        return lang.weekly;
      case Period.monthly:
        return lang.monthly;
    }
  }
}
