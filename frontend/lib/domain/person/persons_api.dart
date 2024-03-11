import 'package:frontend/domain/abstract_api.dart';
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

  Future<Person> patchPerson(
    String id, {
    String? firstName,
    String? lastName,
    Gender? gender,
    String? dateOfBirth,
    String? streetNameNumber,
    String? addressSuffix,
    String? postalCode,
    String? email,
    String? mobileNumber,
    String? comment,
  }) async {
    final $url = '/persons/$id';
    final request = <String, dynamic>{};
    if (firstName != null) request['firstName'] = firstName;
    if (lastName != null) request['lastName'] = lastName;
    if (dateOfBirth != null) request['dateOfBirth'] = dateOfBirth;
    if (gender != null) request['gender'] = Gender.toJson(gender);
    final address = <String, dynamic>{};

    if (streetNameNumber != null) address['streetNameNumber'] = streetNameNumber;
    if (addressSuffix != null) address['addressSuffix'] = addressSuffix;
    if (postalCode != null) address['postalCode'] = postalCode;
    if (email != null) request['email'] = email;
    if (mobileNumber != null) request['mobileNumber'] = mobileNumber;
    if (comment != null) request['comment'] = comment;
    return dioPatch($url, Person.fromJson, data: request);
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
}
