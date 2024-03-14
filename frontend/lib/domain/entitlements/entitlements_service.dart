import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/entitlements/entitlement_value.dart';
import 'package:frontend/domain/entitlements/entitlements_api.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class EntitlementsService {
  EntitlementsService(EntitlementsApi entitlementsApi) : _entitlementsApi = entitlementsApi;

  final EntitlementsApi _entitlementsApi;
  final Logger logger = getLogger();

  //get entitlement
  Future<Entitlement> getEntitlement(String id) async {
    return await _entitlementsApi.getEntitlement(id);
  }

  //getEntitlements
  Future<List<Entitlement>> getEntitlements() async {
    return await _entitlementsApi.getAllEntitlements();
  }

  Future<Entitlement> createEntitlement(
      String personId, String entitlementCauseId, List<EntitlementValue> values) async {
    return await _entitlementsApi.postEntitlement(
        personId: personId, entitlementCauseId: entitlementCauseId, values: values);
  }

  Future<void> updateEntitlement(Entitlement entitlement) async {}

  Future<List<EntitlementCause>> getEntitlementCauses() async {
    return await _entitlementsApi.getAllEntitlementCauses();
  }

  Future<EntitlementCause> getEntitlementCause(String id) async {
    return await _entitlementsApi.getEntitlementCause(id);
  }
}
