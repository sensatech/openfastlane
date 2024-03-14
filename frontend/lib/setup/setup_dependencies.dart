import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/domain/campaign/campaigns_api.dart';
import 'package:frontend/domain/campaign/campaigns_service.dart';
import 'package:frontend/domain/entitlements/entitlements_api.dart';
import 'package:frontend/domain/entitlements/entitlements_service.dart';
import 'package:frontend/domain/login/auth_service.dart';
import 'package:frontend/domain/login/global_login_service.dart';
import 'package:frontend/domain/login/secure_storage_service.dart';
import 'package:frontend/domain/person/persons_api.dart';
import 'package:frontend/domain/person/persons_service.dart';
import 'package:frontend/domain/user/global_user_service.dart';
import 'package:frontend/setup/config/env_config.dart';
import 'package:frontend/ui/admin/campaign/campaign_selection_vm.dart';
import 'package:frontend/ui/admin/entitlements/edit_entitlement_vm.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_vm.dart';
import 'package:frontend/ui/admin/persons/edit_person/edit_person_vm.dart';
import 'package:frontend/ui/admin/persons/edit_person/person_duplicates_cubit.dart';
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
  sl.registerFactory<EntitlementsApi>(() => EntitlementsApi(dioWithAuth));
  sl.registerFactory<CampaignsApi>(() => CampaignsApi(dioWithAuth));

  //services
  sl.registerLazySingleton<PersonsService>(() => PersonsService(sl()));
  sl.registerLazySingleton<AuthService>(() => AuthService(envConfig));
  sl.registerLazySingleton<SecureStorageService>(() => secureStorageService);
  sl.registerLazySingleton<EntitlementsService>(() => EntitlementsService(sl()));
  sl.registerLazySingleton<CampaignsService>(() => CampaignsService(sl()));

  // viewmodels which are singletons, but shoulnd....
  sl.registerLazySingleton<AdminPersonListViewModel>(() => AdminPersonListViewModel(sl(), sl()));

  //view models
  sl.registerFactory<EditPersonViewModel>(() => EditPersonViewModel(sl()));
  sl.registerFactory<AdminPersonViewViewModel>(() => AdminPersonViewViewModel(sl()));
  sl.registerLazySingleton<CampaignSelectionViewModel>(() => CampaignSelectionViewModel(sl()));
  sl.registerFactory<EditEntitlementViewModel>(() => EditEntitlementViewModel(sl(), sl(), sl()));

  //component blocs
  sl.registerFactory<PersonDuplicatesBloc>(() => PersonDuplicatesBloc(sl()));
}
