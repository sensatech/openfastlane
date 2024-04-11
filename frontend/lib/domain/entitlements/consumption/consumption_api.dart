import 'package:frontend/domain/abstract_api.dart';
import 'package:frontend/domain/entitlements/consumption/consumption.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_possibility.dart';

// NOT mocked API
class ConsumptionApi extends AbstractApi {
  ConsumptionApi(super.dio);

  Future<List<Consumption>> getEntitlementConsumptions(String entitlementId) async {
    final $url = '/entitlements/$entitlementId/consumptions';
    return dioGetList($url, Consumption.fromJson);
  }

  Future<List<Consumption>> findConsumptions({
    String? personId,
    String? campaignId,
    String? causeId,
    String? fromString,
    String? toString,
  }) async {
    const $url = '/consumptions/find';
    final data = <String, dynamic>{};
    if (personId != null) data['personId'] = personId;
    if (campaignId != null) data['campaignId'] = campaignId;
    if (causeId != null) data['causeId'] = causeId;
    if (fromString != null) data['from'] = fromString;
    if (toString != null) data['to'] = toString;
    return dioGetList($url, Consumption.fromJson, queryParameters: data);
  }

  Future<Consumption> getEntitlementConsumption(String entitlementId, String id) async {
    final $url = '/entitlements/$entitlementId/consumptions/$id';
    return dioGet($url, Consumption.fromJson);
  }

  Future<ConsumptionPossibility> canConsume(String entitlementId) async {
    final $url = '/entitlements/$entitlementId/can-consume';
    return dioGet($url, ConsumptionPossibility.fromJson);
  }

  Future<Consumption> performConsume(String entitlementId) async {
    final $url = '/entitlements/$entitlementId/consume';
    return dioPost($url, Consumption.fromJson);
  }
}
