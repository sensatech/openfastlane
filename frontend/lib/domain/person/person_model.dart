import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/person/address/address_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'person_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Person extends Equatable {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'firstName')
  final String firstName;

  @JsonKey(name: 'lastName')
  final String lastName;

  @JsonKey(name: 'dateOfBirth')
  final DateTime dateOfBirth;

  @JsonKey(name: 'gender', fromJson: Gender.fromJson, toJson: Gender.toJson)
  final Gender? gender;

  @JsonKey(name: 'address')
  final Address? address;

  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'mobileNumber')
  final String? mobileNumber;

  @JsonKey(name: 'comment')
  final String comment;

  final List<String>? similarPersonIds;

  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;

  const Person(this.id, this.firstName, this.lastName, this.dateOfBirth, this.gender, this.address, this.email,
      this.mobileNumber, this.comment, this.similarPersonIds, this.createdAt, this.updatedAt);

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

  Map<String, dynamic> toJson() => _$PersonToJson(this);

  @override
  List<Object?> get props =>
      [id, firstName, lastName, dateOfBirth, gender, address, email, mobileNumber, comment, createdAt, updatedAt];
}

enum Gender {
  male,
  female,
  diverse,
  unknown;

  static Gender? fromJson(String? value) {
    switch (value) {
      case 'MALE':
        return Gender.male;
      case 'FEMALE':
        return Gender.female;
      case 'DIVERSE':
        return Gender.diverse;
      default:
        return null;
    }
  }

  static String? toJson(Gender? value) {
    switch (value) {
      case Gender.male:
        return 'MALE';
      case Gender.female:
        return 'FEMALE';
      case Gender.diverse:
        return 'DIVERSE';
      default:
        return null;
    }
  }
}

extension GenderExtension on Gender {
  String toLocale(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;

    switch (this) {
      case Gender.male:
        return lang.male;
      case Gender.female:
        return lang.female;
      case Gender.diverse:
        return lang.diverse;
      default:
        return lang.unknown;
    }
  }
}
