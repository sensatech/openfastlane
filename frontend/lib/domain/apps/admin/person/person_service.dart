import 'package:frontend/domain/apps/admin/person/person_model.dart';

class PersonService {
  Future<List<Person>> getAllPersons() async {
    await Future.delayed(const Duration(seconds: 2));
    return [mockPerson1, mockPerson2, mockPerson3];
  }
}

Person mockPerson1 = Person('001', Gender.male, 'Max', 'Mustermann', 'max.m@gmail.com', null,
    'Domstraße', '5', null, '13', 'Wien', '1010', 'acre15fas2', DateTime(1976, 12, 5));

Person mockPerson2 = Person('002', Gender.male, 'Eva', 'Einefrau', 'eva.e@gmail.com', null,
    'Herzogstraße', '18a', '1', '5', 'Wien', '1180', 'acrefafas2', DateTime(1980, 1, 2));

Person mockPerson3 = Person('003', Gender.male, 'Dina', 'Dono', 'dina.d@gmail.com', '06641645216',
    'Lange Straße', '86a', null, '2', 'Wien', '1070', 'gwxeasfas2', DateTime(1990, 5, 12));
