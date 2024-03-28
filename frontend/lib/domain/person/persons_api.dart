import 'package:frontend/domain/abstract_api.dart';
import 'package:frontend/domain/audit_item.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/ui/commons/values/date_format.dart';

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

  Future<Person> postPerson({
    required String firstName,
    required String lastName,
    required Gender gender,
    required DateTime dateOfBirth,
    required String streetNameNumber,
    required String addressSuffix,
    required String postalCode,
    String? email,
    String? mobileNumber,
    String? comment,
  }) async {
    const $url = '/persons?strictMode=false';
    final data = <String, dynamic>{};
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['dateOfBirth'] = getFormattedDate(dateOfBirth);
    data['gender'] = Gender.toJson(gender);
    final address = <String, dynamic>{};
    address['streetNameNumber'] = streetNameNumber;
    address['addressSuffix'] = addressSuffix;
    address['postalCode'] = postalCode;
    data['address'] = address;
    if (email != null) data['email'] = email;
    if (mobileNumber != null) data['mobileNumber'] = mobileNumber;
    if (comment != null) data['comment'] = comment;
    return dioPost($url, Person.fromJson, data: data);
  }

  Future<Person> patchPerson(
    String id, {
    String? firstName,
    String? lastName,
    Gender? gender,
    DateTime? dateOfBirth,
    String? streetNameNumber,
    String? addressSuffix,
    String? postalCode,
    String? email,
    String? mobileNumber,
    String? comment,
  }) async {
    final $url = '/persons/$id';
    final data = <String, dynamic>{};
    if (firstName != null) data['firstName'] = firstName;
    if (lastName != null) data['lastName'] = lastName;
    if (dateOfBirth != null) data['dateOfBirth'] = getFormattedDate(dateOfBirth);
    if (gender != null) data['gender'] = Gender.toJson(gender);
    final address = <String, dynamic>{};

    if (streetNameNumber != null) address['streetNameNumber'] = streetNameNumber;
    if (addressSuffix != null) address['addressSuffix'] = addressSuffix;
    if (postalCode != null) address['postalCode'] = postalCode;
    if (address.isNotEmpty) data['address'] = address;
    if (email != null) data['email'] = email;
    if (mobileNumber != null) data['mobileNumber'] = mobileNumber;
    if (comment != null) data['comment'] = comment;
    return dioPatch($url, Person.fromJson, data: data);
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
    return dioGetList($url, Person.fromJson, queryParameters: parameters);
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

  Future<List<Entitlement>> getPersonEntitlements(String id) async {
    final $url = '/persons/$id/entitlements';
    return dioGetList($url, Entitlement.fromJson);
  }

  Future<List<AuditItem>> getPersonAuditHistory(String id) async {
    final $url = '/persons/$id/history';
    return dioGetList($url, AuditItem.fromJson);
  }
}
