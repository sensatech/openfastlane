import 'package:frontend/domain/abstract_api.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';

// NOT mocked API
class EntitlementsApi extends AbstractApi {
  EntitlementsApi(super.dio);

  Future<List<Entitlement>> getAllEntitlements() async {
    const $url = '/entitlements';
    return dioGetList($url, Entitlement.fromJson);
  }

  Future<Entitlement> getEntitlement(String id) async {
    final $url = '/entitlements/$id';
    return dioGet($url, Entitlement.fromJson);
  }

  Future<List<Entitlement>> getPersonEntitlements(String id) async {
    final $url = '/persons/$id/entitlements';
    return dioGetList($url, Entitlement.fromJson);
  }
}
