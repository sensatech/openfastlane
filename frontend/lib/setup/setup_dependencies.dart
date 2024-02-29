import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/domain/login/auth_service.dart';
import 'package:frontend/domain/login/global_login_service.dart';
import 'package:frontend/domain/login/secure_storage_service.dart';
import 'package:frontend/domain/person/persons_api.dart';
import 'package:frontend/domain/person/persons_service.dart';
import 'package:frontend/domain/user/global_user_serivce.dart';
import 'package:frontend/setup/config/env_config.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_vm.dart';
import 'package:frontend/ui/admin/persons/person_view/admin_person_view_vm.dart';
import 'package:get_it/get_it.dart';

import 'config/dio_config_with_auth.dart';

GetIt sl = GetIt.instance;

void setupDependencies(EnvConfig envConfig) {
  sl.registerSingleton<EnvConfig>(envConfig);

  final secureStorageService = SecureStorageService(const FlutterSecureStorage());
  final authService = AuthService(envConfig);
  sl.registerLazySingleton<GlobalUserService>(() => GlobalUserService());
  var globalLoginService = GlobalLoginService(authService, secureStorageService, sl());

  sl.registerLazySingleton<GlobalLoginService>(() => globalLoginService);

  final dioWithAuth = configureWithAuth(envConfig.apiRootUrl, globalLoginService);
  //APIs
  sl.registerFactory<PersonsApi>(() => PersonsApi(dioWithAuth));

  //services
  sl.registerLazySingleton<PersonsService>(() => PersonsService(sl()));
  sl.registerLazySingleton<AuthService>(() => AuthService(envConfig));
  sl.registerLazySingleton<SecureStorageService>(() => secureStorageService);

  //view models
  sl.registerLazySingleton<AdminPersonListViewModel>(() => AdminPersonListViewModel(sl()));
  sl.registerLazySingleton<AdminPersonViewViewModel>(() => AdminPersonViewViewModel(sl()));
  sl.registerLazySingleton<EditPersonViewModel>(() => EditPersonViewModel(sl()));
  sl.registerLazySingleton<PersonDuplicatesBloc>(() => PersonDuplicatesBloc(sl()));
}
