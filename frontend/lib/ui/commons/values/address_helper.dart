import 'package:frontend/domain/persons/address/address_model.dart';

String getHomeAddressString(Address address) {
  return '${address.streetNameNumber}, ${address.postalCode} Wien';
}
