import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/domain/login/auth_service.dart';
import 'package:frontend/domain/login/global_login_service.dart';
import 'package:frontend/domain/persons/person_service.dart';
import 'package:frontend/setup/config/env_config.dart';
import 'package:frontend/ui/admin/person_list/admin_person_list_view_model.dart';
import 'package:get_it/get_it.dart';

GetIt sl = GetIt.instance;

void setupLocator(EnvConfig envConfig) {
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();

  //APIs
  // sl.registerFactory<PersonApi>(()=> PersonApi());

  //services
  sl.registerLazySingleton<PersonService>(() => PersonService());
  sl.registerLazySingleton<AuthService>(() => AuthService(envConfig));
  sl.registerLazySingleton<GlobalLoginService>(() => GlobalLoginService(secureStorage, sl()));

  //view models
  sl.registerLazySingleton<AdminPersonListViewModel>(() => AdminPersonListViewModel(sl()));
}
