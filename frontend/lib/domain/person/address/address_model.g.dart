// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
      json['streetNameNumber'] as String,
      json['addressSuffix'] as String,
      json['postalCode'] as String,
      json['addressId'] as String?,
      json['gipNameId'] as String?,
    );

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      'streetNameNumber': instance.streetNameNumber,
      'addressSuffix': instance.addressSuffix,
      'postalCode': instance.postalCode,
      'addressId': instance.addressId,
      'gipNameId': instance.gipNameId,
    };
