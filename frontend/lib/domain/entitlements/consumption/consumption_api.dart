import 'package:frontend/domain/abstract_api.dart';
import 'package:frontend/domain/entitlements/consumption/consumption.dart';

import 'consumption_possibility.dart';

// NOT mocked API
class ConsumptionApi extends AbstractApi {
  ConsumptionApi(super.dio);

  Future<List<Consumption>> getEntitlementConsumptions(String entitlementId) async {
    final $url = '/entitlements/$entitlementId/consumptions';
    return dioGetList($url, Consumption.fromJson);
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
