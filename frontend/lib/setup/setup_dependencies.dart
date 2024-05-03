import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/domain/campaign/campaigns_api.dart';
import 'package:frontend/domain/campaign/campaigns_service.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_api.dart';
import 'package:frontend/domain/entitlements/entitlements_api.dart';
import 'package:frontend/domain/entitlements/entitlements_service.dart';
import 'package:frontend/domain/login/auth_service.dart';
import 'package:frontend/domain/login/global_login_service.dart';
import 'package:frontend/domain/login/secure_storage_service.dart';
import 'package:frontend/domain/person/person_search_util.dart';
import 'package:frontend/domain/person/persons_api.dart';
import 'package:frontend/domain/person/persons_service.dart';
import 'package:frontend/domain/reports/exports_api.dart';
import 'package:frontend/domain/reports/reports_service.dart';
import 'package:frontend/domain/user/global_user_service.dart';
import 'package:frontend/setup/config/dio_config_with_auth.dart';
import 'package:frontend/setup/config/env_config.dart';
import 'package:frontend/setup/navigation/navigation_service.dart';
import 'package:frontend/ui/admin/campaign/campaign_selection_vm.dart';
import 'package:frontend/ui/admin/entitlements/create_edit/create_entitlement_vm.dart';
import 'package:frontend/ui/admin/entitlements/create_edit/currency_input_formatter.dart';
import 'package:frontend/ui/admin/entitlements/create_edit/edit_entitlement_vm.dart';
import 'package:frontend/ui/admin/entitlements/view/entitlement_view_vm.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_vm.dart';
import 'package:frontend/ui/admin/persons/edit_person/edit_person_vm.dart';
import 'package:frontend/ui/admin/persons/edit_person/person_duplicates_cubit.dart';
import 'package:frontend/ui/admin/persons/person_view/admin_person_view_vm.dart';
import 'package:frontend/ui/admin/reports/admin_reports_vm.dart';
import 'package:frontend/ui/qr_reader/camera/scanner_camera_vm.dart';
import 'package:frontend/ui/qr_reader/check_entitlement/scanner_entitlement_vm.dart';
import 'package:frontend/ui/qr_reader/choose_campaign/scanner_campaigns_vm.dart';
import 'package:frontend/ui/qr_reader/person_view/scanner_person_view_vm.dart';
import 'package:get_it/get_it.dart';

GetIt sl = GetIt.instance;

void setupDependencies(EnvConfig envConfig) {
  sl.registerSingleton<EnvConfig>(envConfig);

  final secureStorageService = SecureStorageService(const FlutterSecureStorage());
  final authService = AuthService(envConfig);
  sl.registerLazySingleton<GlobalUserService>(() => GlobalUserService());
  var globalLoginService = GlobalLoginService(authService, secureStorageService);

  sl.registerLazySingleton<GlobalLoginService>(() => globalLoginService);

  final dioWithAuth = configureWithAuth(envConfig.apiRootUrl, globalLoginService);
  //APIs
  sl.registerFactory<PersonsApi>(() => PersonsApi(dioWithAuth));
  sl.registerFactory<EntitlementsApi>(() => EntitlementsApi(dioWithAuth));
  sl.registerFactory<CampaignsApi>(() => CampaignsApi(dioWithAuth));
  sl.registerFactory<ConsumptionApi>(() => ConsumptionApi(dioWithAuth));
  sl.registerFactory<ExportsApi>(() => ExportsApi(dioWithAuth));

  //services
  sl.registerLazySingleton<PersonsService>(() => PersonsService(sl(), sl(), sl()));
  sl.registerLazySingleton<AuthService>(() => AuthService(envConfig));
  sl.registerLazySingleton<SecureStorageService>(() => secureStorageService);
  sl.registerLazySingleton<EntitlementsService>(() => EntitlementsService(sl(), sl(), sl(), sl()));
  sl.registerLazySingleton<CampaignsService>(() => CampaignsService(sl()));
  sl.registerLazySingleton<NavigationService>(() => NavigationService());
  sl.registerLazySingleton<ReportsService>(() => ReportsService(sl()));

  // viewmodels which are singletons, but should not....
  sl.registerLazySingleton<AdminPersonListViewModel>(() => AdminPersonListViewModel(sl(), sl()));
  sl.registerLazySingleton<CampaignSelectionViewModel>(() => CampaignSelectionViewModel(sl()));

  //view models
  sl.registerFactory<EditOrCreatePersonViewModel>(() => EditOrCreatePersonViewModel(sl()));
  sl.registerFactory<AdminPersonViewViewModel>(() => AdminPersonViewViewModel(sl()));
  sl.registerFactory<CreateEntitlementViewModel>(() => CreateEntitlementViewModel(sl(), sl(), sl()));
  sl.registerFactory<EditEntitlementViewModel>(() => EditEntitlementViewModel(sl(), sl(), sl()));
  sl.registerFactory<ScannerCampaignsViewModel>(() => ScannerCampaignsViewModel(sl()));
  sl.registerFactory<ScannerEntitlementViewModel>(() => ScannerEntitlementViewModel(sl(), sl()));
  sl.registerFactory<ScannerPersonViewModel>(() => ScannerPersonViewModel(sl(), sl()));
  // sl.registerFactory<ScannerCameraTestVM>(() => ScannerCameraTestVM());
  sl.registerFactory<EntitlementViewViewModel>(() => EntitlementViewViewModel(sl(), sl(), sl()));
  sl.registerFactory<ScannerCameraViewModel>(() => ScannerCameraViewModel(sl(), sl()));
  sl.registerFactory<ScannerCameraViewModel>(() => ScannerCameraViewModel(sl(), sl()));
  sl.registerFactory<AdminReportsViewModel>(() => AdminReportsViewModel(sl()));

  //component blocs/cubits
  sl.registerFactory<PersonDuplicatesBloc>(() => PersonDuplicatesBloc(sl()));

  // other dependencies
  sl.registerFactory<CurrencyInputFormatter>(() => CurrencyInputFormatter());
  sl.registerFactory<PersonSearchUtil>(() => PersonSearchUtil());
}
