import 'package:frontend/domain/persons/person_model.dart';
import 'package:frontend/domain/persons/persons_api.dart';

class PersonService {
  final PersonsApi personsApi;

  PersonService(this.personsApi);

  Future<List<Person>> getAllPersons() async {
    return await personsApi.getAllPersons();
  }
}
