import 'package:frontend/domain/abstract_api.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class MockedPersonsApi extends AbstractApi {
  MockedPersonsApi(super.dio);

  @override
  Logger logger = getLogger();

  Future<List<Person>> getAllPersons() async {
    /* const $url = '/persons';
    return dioGetList($url, Person.fromJson);*/

    List<Person> persons = [];

    try {
      logger.i('fetching all persons');
      await Future.delayed(const Duration(seconds: 2));
      persons = getMockedJsonResponseList(15).map((json) => Person.fromJson(json)).toList();
    } catch (e) {
      logger.e('error fetching all persons: $e');
    }
    return persons;
  }

  Future<List<Person>> findSimilarPersons({String? firstName, String? lastName, DateTime? dateOfBirth}) async {
    /*var $url = '/persons/$personId/findSimilarPersons';
    var params = {'firstName': firstName, 'lastName': lastName, 'dateOfBirth': dateOfBirth.toIso8601String()};
    return dioGetList($url, Person.fromJson, parameters: params);*/

    List<Person> persons = [];

    try {
      logger.i('fetching similar persons');
      await Future.delayed(const Duration(seconds: 2));
      persons = getMockedDuplicates(firstName!).map((json) => Person.fromJson(json)).toList();
    } catch (e) {
      logger.e('error fetching similar persons: $e');
    }
    return persons;
  }
}

// mock data

List<dynamic> mockedPersonJson = [
  {
    "id": "65cb44dd37328f14efc22793",
    "firstName": "Adam",
    "lastName": "Smith",
    "dateOfBirth": "1980-10-10",
    "gender": "DIVERSE",
    "address": {
      "streetNameNumber": "Main Street 1",
      "addressSuffix": "1",
      "postalCode": "1234",
      "addressId": "65cb44dd37328f14efc22794",
      "gipNameId": null
    },
    "email": "mail@example.com",
    "mobileNumber": "+43 123 456 789",
    "comment": "",
    "similarPersonIds": [],
    "createdAt": "2024-02-13T10:30:53.995227821Z",
    "updatedAt": "2024-02-13T10:30:53.995247621Z"
  },
  {
    "id": "65ccc7b555e16444da78ca5e",
    "firstName": "Adam",
    "lastName": "Smith",
    "dateOfBirth": "1980-10-10",
    "gender": "DIVERSE",
    "address": {
      "streetNameNumber": "Small Avenue",
      "addressSuffix": "1",
      "postalCode": "1234",
      "addressId": "65ccc7b555e16444da78ca5f",
      "gipNameId": null
    },
    "email": "mail@example.com",
    "mobileNumber": "+43 123 456 789",
    "comment": "",
    "similarPersonIds": [],
    "createdAt": "2024-02-14T14:01:25.00787165Z",
    "updatedAt": "2024-02-14T14:01:25.007883651Z"
  },
  {
    "id": "65ccc7b555e16444da71256f",
    "firstName": "Peter",
    "lastName": "Meier",
    "dateOfBirth": "1980-10-10",
    "gender": "MALE",
    "address": {
      "streetNameNumber": "Straße 1",
      "addressSuffix": "1",
      "postalCode": "1234",
      "addressId": "65ccc7b555e16444da78ca5f",
      "gipNameId": null
    },
    "email": "mail@example.com",
    "mobileNumber": "+43 123 456 789",
    "comment": "Ist sehr sehr lustig",
    "similarPersonIds": [],
    "createdAt": "2024-02-14T14:01:25.00787165Z",
    "updatedAt": "2024-02-14T14:01:25.007883651Z"
  },
  {
    "id": "65ccc7b555e16444da78ca60",
    "firstName": "Adam",
    "lastName": "Smith",
    "dateOfBirth": "1980-10-10",
    "gender": "DIVERSE",
    "address": {
      "streetNameNumber": "Main Street 1",
      "addressSuffix": "1",
      "postalCode": "1234",
      "addressId": "65ccc7b555e16444da78ca61",
      "gipNameId": null
    },
    "email": "mail@example.com",
    "mobileNumber": "+43 123 456 789",
    "comment": "",
    "similarPersonIds": [],
    "createdAt": "2024-02-14T14:01:25.007895752Z",
    "updatedAt": "2024-02-14T14:01:25.007899352Z"
  },
  {
    "id": "65ccc7b555e16444da78ca62",
    "firstName": "Adam",
    "lastName": "Smith",
    "dateOfBirth": "1980-10-10",
    "gender": "DIVERSE",
    "address": {
      "streetNameNumber": "Main Street 1",
      "addressSuffix": "1",
      "postalCode": "1234",
      "addressId": "65ccc7b555e16444da78ca63",
      "gipNameId": null
    },
    "email": "mail@example.com",
    "mobileNumber": "+43 123 456 789",
    "comment": "",
    "similarPersonIds": [],
    "createdAt": "2024-02-14T14:01:25.007907453Z",
    "updatedAt": "2024-02-14T14:01:25.007910653Z"
  },
  {
    "id": "65ccc7b555e16444da78ca64",
    "firstName": "Adam",
    "lastName": "Smith",
    "dateOfBirth": "1980-10-10",
    "gender": "DIVERSE",
    "address": {
      "streetNameNumber": "Main Street 1",
      "addressSuffix": "1",
      "postalCode": "1234",
      "addressId": "65ccc7b555e16444da78ca65",
      "gipNameId": null
    },
    "email": "mail@example.com",
    "mobileNumber": "+43 123 456 789",
    "comment": "",
    "similarPersonIds": [],
    "createdAt": "2024-02-14T14:01:25.007917953Z",
    "updatedAt": "2024-02-14T14:01:25.007920754Z"
  }
];

List<dynamic> getMockedJsonResponseList(int listLength) {
  return List.generate(listLength, (index) => mockedPersonJson[index % mockedPersonJson.length]);
}

List getMockedDuplicates(String firstName) {
  if (firstName == 'Adam') {
    return mockedSimilarPersonsResponse;
  } else {
    return [];
  }
}

final mockedSimilarPersonsResponse = [
  {
    "id": "65ccc7b555e16444da78ca5e",
    "firstName": "Adam",
    "lastName": "Smith",
    "dateOfBirth": "1980-10-10",
    "gender": "DIVERSE",
    "address": {
      "streetNameNumber": "Main Street 1",
      "addressSuffix": "1",
      "postalCode": "1234",
      "addressId": "65ccc7b555e16444da78ca5f",
      "gipNameId": null
    },
    "email": "mail@example.com",
    "mobileNumber": "+43 123 456 789",
    "comment": "Ist lustig",
    "similarPersonIds": [],
    "createdAt": "2024-02-14T14:01:25.00787165Z",
    "updatedAt": "2024-02-14T14:01:25.007883651Z"
  },
  {
    "id": "65ccc7b555e16444da78ca60",
    "firstName": "Adam",
    "lastName": "Smith",
    "dateOfBirth": "1980-10-10",
    "gender": "DIVERSE",
    "address": {
      "streetNameNumber": "Main Street 1",
      "addressSuffix": "1",
      "postalCode": "1234",
      "addressId": "65ccc7b555e16444da78ca61",
      "gipNameId": null
    },
    "email": "mail@example.com",
    "mobileNumber": "+43 123 456 789",
    "comment": "Ist lustig",
    "similarPersonIds": [],
    "createdAt": "2024-02-14T14:01:25.007895752Z",
    "updatedAt": "2024-02-14T14:01:25.007899352Z"
  },
  {
    "id": "65ccc7b555e16444da78ca62",
    "firstName": "Adam",
    "lastName": "Smith",
    "dateOfBirth": "1980-10-10",
    "gender": "DIVERSE",
    "address": {
      "streetNameNumber": "Main Street 1",
      "addressSuffix": "1",
      "postalCode": "1234",
      "addressId": "65ccc7b555e16444da78ca63",
      "gipNameId": null
    },
    "email": "mail@example.com",
    "mobileNumber": "+43 123 456 789",
    "comment": "",
    "similarPersonIds": [],
    "createdAt": "2024-02-14T14:01:25.007907453Z",
    "updatedAt": "2024-02-14T14:01:25.007910653Z"
  },
  {
    "id": "65ccc7b555e16444da78ca64",
    "firstName": "Adam",
    "lastName": "Smith",
    "dateOfBirth": "1980-10-10",
    "gender": "DIVERSE",
    "address": {
      "streetNameNumber": "Main Street 1",
      "addressSuffix": "1",
      "postalCode": "1234",
      "addressId": "65ccc7b555e16444da78ca65",
      "gipNameId": null
    },
    "email": "mail@example.com",
    "mobileNumber": "+43 123 456 789",
    "comment": "",
    "similarPersonIds": [],
    "createdAt": "2024-02-14T14:01:25.007917953Z",
    "updatedAt": "2024-02-14T14:01:25.007920754Z"
  }
];
