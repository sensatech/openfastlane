import 'package:frontend/domain/persons/address/address_model.dart';
import 'package:frontend/domain/persons/person_model.dart';

class PersonService {
  Future<List<Person>> getAllPersons() async {
    await Future.delayed(const Duration(seconds: 2));
    return [mockPerson1, mockPerson2, mockPerson3];
  }
}

Person mockPerson1 = Person(
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

Person mockPerson2 = Person(
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

Person mockPerson3 = Person(
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
