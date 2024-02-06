import 'package:frontend/domain/persons/person_service.dart';
import 'package:frontend/ui/apps/admin/person_list/admin_person_list_view_model.dart';
import 'package:get_it/get_it.dart';

GetIt sl = GetIt.instance;

void setupLocator() {
  //APIs
  // sl.registerFactory<PersonApi>(()=> PersonApi());

  //services
  sl.registerLazySingleton<PersonService>(() => PersonService());

  //view models
  sl.registerLazySingleton<AdminPersonListViewModel>(() => AdminPersonListViewModel(sl()));
}
