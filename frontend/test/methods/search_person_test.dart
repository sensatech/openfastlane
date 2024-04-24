import 'package:frontend/domain/person/address/address_model.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/domain/person/person_search_util.dart';
import 'package:frontend/setup/config/env_config.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:test/test.dart';

void main() {
  late PersonSearchUtil personSearchUtil;
  setupDependencies(configLocal);
  setUp(() {
    personSearchUtil = sl<PersonSearchUtil>();
  });

  group('Person Search Tests', () {
    // Dummy data setup
    const address1 = Address('123 Baker Street', 'Apt 1', '90210', 'address1', 'gip1');
    const address2 = Address('456 Elm Street', 'Apt 2', '80120', 'address2', 'gip2');
    const address3 = Address('789 Pine Street', 'Apt 3', '80301', 'address3', 'gip3');

    final person1 = Person('1', 'John', 'Doe', null, Gender.male, address1, 'john@example.com', '1234567890',
        'No comments', null, DateTime.now(), DateTime.now(), null, null);
    final person2 = Person('2', 'Jane', 'Doe', null, Gender.female, address2, 'jane@example.com', '0987654321',
        'No comments', null, DateTime.now(), DateTime.now(), null, null);
    final person3 = Person('3', 'Alice', 'Johnson', null, Gender.diverse, address3, 'alice@example.com', '1231231234',
        'No comments', null, DateTime.now(), DateTime.now(), null, null);

    List<Person> persons = [person1, person2, person3];

    // Define tests for each scenario
    test('Search by correct first name', () {
      String searchInput = 'Jane';
      var results = personSearchUtil.getFilteredPersons(persons, searchInput);
      expect(results.length, 1);
      expect(results, contains(person2));
    });

    // Define tests for each scenario
    test('Search by correct first name (person 1) and partly last name (person 3)', () {
      String searchInput = 'John';
      var results = personSearchUtil.getFilteredPersons(persons, searchInput);
      expect(results.length, 2);
      expect(results, containsAll([person1, person3]));
    });

    test('Search by correct last name', () {
      String searchInput = 'Doe';
      var results = personSearchUtil.getFilteredPersons(persons, searchInput);
      expect(results.length, 2);
      expect(results, containsAll([person1, person2]));
    });

    // mulitple words address, correct address
    test('Search by correct address with single word', () {
      String searchInput = 'Baker';
      var results = personSearchUtil.getFilteredPersons(persons, searchInput);
      expect(results.length, 1);
      expect(results, contains(person1));
    });

    // mulitple words address, correct address
    test('Search by correct address with multiple words', () {
      String searchInput = '123 Baker Street';
      var results = personSearchUtil.getFilteredPersons(persons, searchInput);
      expect(results.length, 1);
      expect(results, contains(person1));
    });

    // Only one word, none correct
    test('Search with non-matching single word', () {
      String searchInput = 'Random';
      var results = personSearchUtil.getFilteredPersons(persons, searchInput);
      expect(results.isEmpty, isTrue);
    });

    // Two words: correct firstName, correct lastName
    test('Search with correct firstName and lastName', () {
      String searchInput = 'John Doe';
      var results = personSearchUtil.getFilteredPersons(persons, searchInput);
      expect(results.length, 1);
      expect(results, contains(person1));
    });

    // Two words: correct firstName, not correct lastName
    test('Search with correct firstName and incorrect lastName', () {
      String searchInput = 'John Smith';
      var results = personSearchUtil.getFilteredPersons(persons, searchInput);
      expect(results.isEmpty, isTrue);
    });

    // Two words separated by comma: correct firstName and address
    test('Search with firstName and address', () {
      String searchInput = 'John, 123 Baker Street';
      var results = personSearchUtil.getFilteredPersons(persons, searchInput);
      expect(results.length, 1);
      expect(results, contains(person1));
    });

    // Two words separated by comma: correct firstName and wrong address
    test('Search with correct firstName and wrong address', () {
      String searchInput = 'John, 999 Some Street';
      var results = personSearchUtil.getFilteredPersons(persons, searchInput);
      expect(results.isEmpty, isTrue);
    });

    // Three words separated by comma: correct firstName, lastName and address
    test('Search with firstName, lastName, and address', () {
      String searchInput = 'John Doe, 123 Baker Street';
      var results = personSearchUtil.getFilteredPersons(persons, searchInput);
      expect(results.length, 1);
      expect(results, contains(person1));
    });

    // Two words: lastName + firstName, both correct but in reverse order
    test('Search with lastName and firstName in reverse order', () {
      String searchInput = 'Doe John';
      var results = personSearchUtil.getFilteredPersons(persons, searchInput);
      expect(results.length, 1);
      expect(results, contains(person1));
    });

    // Three words separated by comma: correct firstName, lastName and wrong address
    test('Search with correct firstName, lastName and wrong address', () {
      String searchInput = 'John Doe, 404 Missing Way';
      var results = personSearchUtil.getFilteredPersons(persons, searchInput);
      expect(results.isEmpty, isTrue);
    });

    // Three words separated by comma: correct firstName, lastName and wrong address
    test('Search with correct firstName, lastName and wrong address', () {
      String searchInput = 'John Doe, 404 Missing Way';
      var results = personSearchUtil.getFilteredPersons(persons, searchInput);
      expect(results.isEmpty, isTrue);
    });
  });
}
