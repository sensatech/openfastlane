import 'package:frontend/domain/abstract_api.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/person/person_model.dart';

// NOT mocked API
class PersonsApi extends AbstractApi {
  PersonsApi(super.dio);

  Future<List<Person>> getAllPersons() async {
    const $url = '/persons';
    return dioGetList($url, Person.fromJson);
  }

  Future<Person> getPerson(String id) async {
    final $url = '/persons/$id';
    return dioGet($url, Person.fromJson);
  }

  Future<List<Person>> getPersonSimilarOnes(String id) async {
    const $url = '/persons';
    return dioGetList($url, Person.fromJson);
  }

  Future<List<Person>> findSimilarPersons({String? firstName, String? lastName, DateTime? dateOfBirth}) async {
    const $url = '/persons/findSimilarPersons';
    final parameters = <String, dynamic>{};
    if (firstName != null) parameters['firstName'] = firstName;
    if (lastName != null) parameters['lastName'] = lastName;
    if (dateOfBirth != null) parameters['dateOfBirth'] = dateOfBirth.toIso8601String().substring(0, 10);
    return dioGetList($url, Person.fromJson);
  }

  Future<List<Person>> findSimilarAddresses(
      {String? addressId, String? addressSuffix, String? streetNameNumber}) async {
    const $url = '/persons/findWithSimilarAddress';
    final parameters = <String, dynamic>{};
    if (addressId != null) parameters['addressId'] = addressId;
    if (addressSuffix != null) parameters['addressSuffix'] = addressSuffix;
    if (streetNameNumber != null) parameters['streetNameNumber'] = streetNameNumber;
    return dioGetList($url, Person.fromJson);
  }

  // might be moved to EntitlementsApi
  Future<List<Entitlement>> getPersonEntitlements(String id) async {
    final $url = '/persons/$id/entitlements';
    return dioGetList($url, Entitlement.fromJson);
  }
}
