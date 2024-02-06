import 'package:frontend/domain/abstract_api.dart';
import 'package:frontend/domain/persons/person_model.dart';

class PersonsApi extends AbstractApi {
  PersonsApi(super.dio);

  Future<List<Person>> getAllPersons() {
    const $url = '/admin/persons';
    return dioGetList($url, Person.fromJson);
  }
}
