import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'address_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Address extends Equatable {
  @JsonKey(name: 'streetNameNumber')
  final String streetNameNumber;

  @JsonKey(name: 'addressSuffix')
  final String addressSuffix;

  @JsonKey(name: 'postalCode')
  final String postalCode;

  @JsonKey(name: 'addressId')
  final String? addressId;

  @JsonKey(name: 'gipNameId')
  final String? gipNameId;

  const Address(
      this.streetNameNumber, this.addressSuffix, this.postalCode, this.addressId, this.gipNameId);

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);

  Map<String, dynamic> toJson() => _$AddressToJson(this);

  @override
  List<Object?> get props => [streetNameNumber, addressSuffix, postalCode, addressId, gipNameId];
}

extension AddressExtension on Address {
  String get fullAddressAsString => '$streetNameNumber $addressSuffix, $postalCode';
}
