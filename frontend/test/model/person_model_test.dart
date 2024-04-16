import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/domain/person/address/address_model.dart';
import 'package:frontend/domain/person/person_model.dart';

void main() {
  group('Person', () {
    test('fromJson() should properly deserialize JSON', () {
      const jsonString = '''
        {
          "id" : "65ccc7b455e16444da78ca15",
          "firstName" : "Adam",
          "lastName" : "Smith",
          "dateOfBirth" : "1980-10-10",
          "gender" : "DIVERSE",
          "address" : {
            "streetNameNumber" : "Main Street 1",
            "addressSuffix" : "1",
            "postalCode" : "1234",
            "addressId" : "65ccc7b455e16444da78ca16",
            "gipNameId" : null
          },
          "email" : "mail@example.com",
          "mobileNumber" : "+43 123 456 789",
          "comment" : "",
          "similarPersonIds" : [ ],
          "createdAt" : "2024-02-14T14:01:24.756347488Z",
          "updatedAt" : "2024-02-14T14:01:24.756760621Z"
        }
      ''';

      final Map<String, dynamic> jsonMap = json.decode(jsonString);

      final Person person = Person.fromJson(jsonMap);

      expect(person.id, '65ccc7b455e16444da78ca15');
      expect(person.firstName, 'Adam');
      expect(person.lastName, 'Smith');
      expect(person.dateOfBirth, DateTime.parse('1980-10-10'));
      expect(person.gender, Gender.diverse);
      expect(person.email, 'mail@example.com');
      expect(person.mobileNumber, '+43 123 456 789');
      expect(person.comment, '');
      expect(person.address!.streetNameNumber, 'Main Street 1');
      expect(person.address!.addressSuffix, '1');
      expect(person.address!.postalCode, '1234');
      expect(person.address!.addressId, '65ccc7b455e16444da78ca16');
      expect(person.address!.gipNameId, null);
      expect(person.similarPersonIds, []);
      expect(person.createdAt, DateTime.parse('2024-02-14T14:01:24.756347488Z'));
      expect(person.updatedAt, DateTime.parse('2024-02-14T14:01:24.756760621Z'));
    });

    test('toJson() should properly serialize object to JSON', () {
      const address = Address('Main Street 1', '1', '1234', '65ccc7b455e16444da78ca16', null);

      final person = Person(
          '65ccc7b455e16444da78ca15',
          'Adam',
          'Smith',
          DateTime(1980, 10, 10),
          Gender.diverse,
          address,
          'mail@example.com',
          '+43 123 456 789',
          '',
          const [],
          DateTime.parse('2024-02-14T14:01:24.000'),
          DateTime.parse('2024-02-14T14:01:24.000'),
          const [],
          const []);

      final Map<String, dynamic> jsonMap = person.toJson();

      expect(jsonMap['id'], '65ccc7b455e16444da78ca15');
      expect(jsonMap['firstName'], 'Adam');
      expect(jsonMap['lastName'], 'Smith');
      expect(jsonMap['dateOfBirth'], '1980-10-10T00:00:00.000');
      expect(jsonMap['gender'], 'DIVERSE');
      expect(jsonMap['email'], 'mail@example.com');
      expect(jsonMap['mobileNumber'], '+43 123 456 789');
      expect(jsonMap['comment'], '');
      expect(jsonMap['address']['streetNameNumber'], 'Main Street 1');
      expect(jsonMap['address']['addressSuffix'], '1');
      expect(jsonMap['address']['postalCode'], '1234');
      expect(jsonMap['address']['addressId'], '65ccc7b455e16444da78ca16');
      expect(jsonMap['address']['gipNameId'], null);
      expect(jsonMap['similarPersonIds'], []);
      expect(jsonMap['createdAt'], '2024-02-14T14:01:24.000');
      expect(jsonMap['updatedAt'], '2024-02-14T14:01:24.000');
    });
  });
}
