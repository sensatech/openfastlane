import 'package:frontend/domain/abstract_api.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class PersonApi extends AbstractApi {
  PersonApi(super.dio);

  Logger logger = getLogger();

  Future<List<Person>> getAllPersons() async {
    //TODO: implement when backend works locally
    /* const $url = '/persons';
    return dioGetList($url, Person.fromJson);*/

    List<Person> persons = [];

    try {
      logger.i('fetching all persons');
      await Future.delayed(const Duration(seconds: 2));
      persons = mockedJsonResponseList(15).map((json) => Person.fromJson(json)).toList();
    } catch (e) {
      logger.e('error fetching all persons: $e');
    }
    return persons;
  }
}

final mockedJsonResponse = {
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
};

List<dynamic> mockedJsonResponseList(int listLength) {
  return List.generate(listLength, (index) => mockedJsonResponse);
}
