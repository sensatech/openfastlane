import 'package:equatable/equatable.dart';
import 'package:frontend/domain/persons/address/address_model.dart';
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

  @JsonKey(name: 'gender')
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

enum Gender { MALE, FEMALE, DIVERSE }
