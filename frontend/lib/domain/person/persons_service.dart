import 'package:collection/collection.dart';
import 'package:frontend/domain/audit_item.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_api.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class PersonsService {
  final PersonsApi personsApi;

  PersonsService(this.personsApi);

  Logger logger = getLogger();

  List<Person> _cachedPersons = [];

  Future<List<Person>> getAllPersons() async {
    if (_cachedPersons.isEmpty) {
      logger.i('fetching all persons');
      _cachedPersons = await personsApi.getAllPersons();
    }
    return _cachedPersons;
  }

  Future<Person?> getSinglePerson(String personId) async {
    List<Person> persons = await getAllPersons();
    Person? person = persons.firstWhereOrNull((person) => person.id == personId);
    if (person == null) {
      logger.e('no Person found');
    }
    return person;
  }

  Future<List<Entitlement>?> getPersonEntitlements(String personId) async {
    try {
      var personEntitlements = await personsApi.getPersonEntitlements(personId);
      return personEntitlements;
    } catch (e) {
      logger.e('Error while fetching entitlements for person $personId: $e');
      return null;
    }
  }

  Future<List<AuditItem>?> getPersonHistory(String personId) async {
    try {
      return await personsApi.getPersonAuditHistory(personId);
    } catch (e) {
      logger.e('Error while fetching getPersonHistory for person $personId: $e');
      return null;
    }
  }

  Future<List<Person>> getSimilarPersons(String firstName, String lastName, DateTime dateOfBirth) async {
    logger.i('fetching similar persons');
    return personsApi.findSimilarPersons(firstName: firstName, lastName: lastName, dateOfBirth: dateOfBirth);
  }

  Future<Person> updatePerson(
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
  }) {
    logger.i('fetching similar persons');
    return personsApi.patchPerson(
      id,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
      gender: gender,
      streetNameNumber: streetNameNumber,
      addressSuffix: addressSuffix,
      postalCode: postalCode,
      email: email,
      mobileNumber: mobileNumber,
      comment: comment,
    );
  }

  Future<Person> createPerson({
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
  }) {
    return personsApi.postPerson(
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        dateOfBirth: dateOfBirth,
        streetNameNumber: streetNameNumber,
        addressSuffix: addressSuffix,
        postalCode: postalCode,
        email: email,
        mobileNumber: mobileNumber,
        comment: comment);
  }

  Future<void> invalidateCache() async {
    _cachedPersons = [];
  }
}
