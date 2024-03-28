import 'package:frontend/domain/abstract_api.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/entitlements/entitlement_value.dart';

// NOT mocked API
class EntitlementsApi extends AbstractApi {
  EntitlementsApi(super.dio);

  Future<List<Entitlement>> getAllEntitlements() async {
    const $url = '/entitlements';
    Future<List<Entitlement>> result = dioGetList($url, Entitlement.fromJson);
    return result;
  }

  Future<Entitlement> getEntitlement(String id) async {
    final $url = '/entitlements/$id';
    return dioGet($url, Entitlement.fromJson);
  }

  Future<Entitlement> createEntitlement(
      {required String personId, required String entitlementCauseId, required List<EntitlementValue> values}) async {
    const $url = '/entitlements';
    final data = <String, dynamic>{};
    data['personId'] = personId;
    data['entitlementCauseId'] = entitlementCauseId;
    data['values'] = values.map((e) => e.toJson()).toList();
    return dioPost($url, Entitlement.fromJson, data: data);
  }

  Future<List<EntitlementCause>> getAllEntitlementCauses() async {
    const $url = '/entitlement-causes';
    return dioGetList($url, EntitlementCause.fromJson);
  }

  Future<EntitlementCause> getEntitlementCause(String id) async {
    final $url = '/entitlement-causes/$id';
    return dioGet($url, EntitlementCause.fromJson);
  }
}
