import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/domain/login/auth_service.dart';
import 'package:frontend/domain/login/global_login_service.dart';
import 'package:frontend/domain/login/secure_storage_service.dart';
import 'package:frontend/domain/persons/person_service.dart';
import 'package:frontend/setup/config/env_config.dart';
import 'package:frontend/ui/admin/person_list/admin_person_list_view_model.dart';
import 'package:get_it/get_it.dart';

GetIt sl = GetIt.instance;

void setupLocator(EnvConfig envConfig) {
  sl.registerSingleton<FlutterSecureStorage>(const FlutterSecureStorage());
  sl.registerSingleton<EnvConfig>(envConfig);

  //APIs
  // sl.registerFactory<PersonApi>(()=> PersonApi());

  //services
  sl.registerLazySingleton<PersonService>(() => PersonService());
  sl.registerLazySingleton<AuthService>(() => AuthService(envConfig));
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService(sl()));
  sl.registerLazySingleton<GlobalLoginService>(() => GlobalLoginService(sl(), sl()));

  //view models
  sl.registerLazySingleton<AdminPersonListViewModel>(() => AdminPersonListViewModel(sl()));
}
