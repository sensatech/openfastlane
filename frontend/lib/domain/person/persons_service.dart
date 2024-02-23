import 'package:collection/collection.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/persons_api.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class PersonsService {
  final PersonsApi personApi;

  PersonsService(this.personApi);

  Logger logger = getLogger();

  List<Person> _cachedPersons = [];

  Future<List<Person>> getAllPersons() async {
    if (_cachedPersons.isEmpty) {
      logger.i('fetching all persons');
      _cachedPersons = await personApi.getAllPersons();
    }
    return _cachedPersons;
  }

  Future<List<PersonWithEntitlementsInfo>> getAllPersonsWithInfo() async {
    if (_cachedPersons.isEmpty) {
      logger.i('fetching all persons');
      _cachedPersons = await personApi.getAllPersons();
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

  //TODO: implement real as soon as backend is ready
  Future<DateTime> getLastCollectionDate(String campaignId, String personId) async {
    return DateTime.now().subtract(const Duration(days: 10));
  }

  //TODO: implement real as soon as backend is ready
  Future<DateTime> getEntitlementValidUntil(String campaignId, String personId) async {
    return DateTime.now().add(const Duration(days: 100));
  }

  Future<List<Person>> getSimilarPersons(String firstName, String lastName, DateTime dateOfBirth) async {
    logger.i('fetching similar persons');
    return personApi.getSimilarPersons(firstName, lastName, dateOfBirth);
  }
}

class PersonWithEntitlementsInfo {
  final Person person;
  final DateTime lastCollection;
  final DateTime entitlementValidUntil;

  PersonWithEntitlementsInfo(this.person, this.lastCollection, this.entitlementValidUntil);
}
