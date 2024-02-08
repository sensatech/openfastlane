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

  //TODO: add method to parse date
  @JsonKey(name: 'dateOfBirth')
  final DateTime dateOfBirth;

  //TODO: add methods to get gender from String
  @JsonKey(name: 'gender')
  final Gender? gender;

  @JsonKey(name: 'address')
  final Address address;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'mobileNumber')
  final String mobileNumber;

  @JsonKey(name: 'comment')
  final String comment;

  //TODO: add method to parse date
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  //TODO: add method to parse date
  @JsonKey(name: 'updatedAt')
  final DateTime updatedAt;

  const Person(this.id, this.firstName, this.lastName, this.dateOfBirth, this.gender, this.address,
      this.email, this.mobileNumber, this.comment, this.createdAt, this.updatedAt);

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

  Map<String, dynamic> toJson() => _$PersonToJson(this);

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        dateOfBirth,
        gender,
        address,
        email,
        mobileNumber,
        comment,
        createdAt,
        updatedAt
      ];
}

enum Gender { male, female, diverse }
