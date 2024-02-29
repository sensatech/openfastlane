import 'package:collection/collection.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlements_api.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_api.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class PersonService {
  final PersonsApi personsApi;
  final EntitlementsApi entitlementsApi;

  PersonService(this.personsApi, this.entitlementsApi);

  Logger logger = getLogger();

  List<Person> _cachedPersons = [];

  Future<List<Person>> getAllPersons() async {
    if (_cachedPersons.isEmpty) {
      logger.i('fetching all persons');
      _cachedPersons = await personsApi.getAllPersons();
    }
    return _cachedPersons;
  }

  Future<List<PersonWithEntitlementsInfo>> getAllPersonsWithInfo() async {
    if (_cachedPersons.isEmpty) {
      logger.i('fetching all persons');
      _cachedPersons = await personsApi.getAllPersons();
    }
    return _getInfos(_cachedPersons);
  }

  Future<List<PersonWithEntitlementsInfo>> _getInfos(List<Person> persons) {
    return Future.wait(persons.map((person) async {
      DateTime lastCollection = await getLastCollectionDate('campaignId', person.id);
      DateTime entitlementValidUntil = await getEntitlementValidUntil('campaignId', person.id);
      return PersonWithEntitlementsInfo(person, lastCollection, entitlementValidUntil);
    }).toList());
  }

  Future<Person?> getSinglePerson(String personId) async {
    Person? person =
        await getAllPersons().then((persons) => persons.firstWhereOrNull((person) => person.id == personId));
    return person;
  }

  Future<List<Entitlement>?> getPersonEntitlements(String personId) async {
    try {
      var personEntitlements = await entitlementsApi.getPersonEntitlements(personId);
      return personEntitlements;
    } catch (e) {
      logger.e('Error while fetching entitlements for person $personId: $e');
      return null;
    }
  }

  //TODO: implement real as soon as backend is ready
  Future<DateTime> getLastCollectionDate(String campaignId, String personId) async {
    return DateTime.now().subtract(const Duration(days: 10));
  }

  //TODO: implement real as soon as backend is ready
  Future<DateTime> getEntitlementValidUntil(String campaignId, String personId) async {
    return DateTime.now().add(const Duration(days: 100));
  }
}

class PersonWithEntitlementsInfo {
  final Person person;
  final DateTime lastCollection;
  final DateTime entitlementValidUntil;

  PersonWithEntitlementsInfo(this.person, this.lastCollection, this.entitlementValidUntil);
}
