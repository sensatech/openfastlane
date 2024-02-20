import 'package:frontend/domain/abstract_api.dart';
import 'package:frontend/domain/person/person_model.dart';

class PersonsApi extends AbstractApi {
  PersonsApi(super.dio);

  Future<List<Person>> getAllPersons() {
    const $url = '/persons';
    return dioGetList($url, Person.fromJson);
  }
}
