import 'package:collection/collection.dart';
import 'package:frontend/domain/person/person_api.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class PersonService {
  final PersonApi personApi;

  PersonService(this.personApi);

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
}

class PersonWithEntitlementsInfo {
  final Person person;
  final DateTime lastCollection;
  final DateTime entitlementValidUntil;

  PersonWithEntitlementsInfo(this.person, this.lastCollection, this.entitlementValidUntil);
}

/*
@Deprecated('use PersonApi instead')
Person _mockPerson1 = Person(
    '001',
    'Max',
    'Mustermann',
    DateTime(1976, 12, 5),
    Gender.male,
    const Address('Hauptstraße 2', '2/4', '1180', 'gsafjkalk12', 'gip001'),
    'peter@gmail.com',
    '06641234567',
    'ein Kommentar',
    DateTime(2021, 1, 1, 13, 52, 12),
    DateTime(2021, 1, 1, 15, 12, 51));

@Deprecated('use PersonApi instead')
Person _mockPerson2 = Person(
    '002',
    'Eva',
    'Einefrau',
    DateTime(1981, 12, 5),
    Gender.female,
    const Address('Wiesengasse 5', '4', '1110', 'gsafjasd412', 'gip002'),
    'eva@gmail.com',
    '06641234567',
    'zwei Kommentar',
    DateTime(2021, 1, 1, 13, 52, 12),
    DateTime(2021, 1, 1, 15, 12, 51));

@Deprecated('use PersonApi instead')
Person _mockPerson3 = Person(
    '003',
    'Dina',
    'Dino',
    DateTime(1996, 5, 30),
    Gender.female,
    const Address('Eisengasse 7', '4', '1210', 'asdf3452gfdsf', 'gip003'),
    'dina@gmail.com',
    '06641234567',
    'drei Kommentar',
    DateTime(2021, 1, 1, 13, 52, 12),
    DateTime(2021, 1, 1, 15, 12, 51));
*/
