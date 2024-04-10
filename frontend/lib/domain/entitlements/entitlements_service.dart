import 'package:frontend/domain/campaign/campaigns_api.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/entitlements/entitlement_value.dart';
import 'package:frontend/domain/entitlements/entitlements_api.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

import '../person/persons_api.dart';

class EntitlementsService {
  EntitlementsService(this._entitlementsApi, this._personsApi, this._campaignsApi);

  final EntitlementsApi _entitlementsApi;
  final PersonsApi _personsApi;
  final CampaignsApi _campaignsApi;
  final Logger logger = getLogger();

  //get entitlement
  Future<Entitlement> getEntitlement(String id, {bool full = false}) async {
    final result = await _entitlementsApi.getEntitlement(id);
    if (full) {
      final person = await _personsApi.getPerson(result.personId);
      final entitlementCause = await _entitlementsApi.getEntitlementCause(result.entitlementCauseId);
      final campaign = await _campaignsApi.getCampaign(entitlementCause.campaignId);
      return result.copyWith(person: person, entitlementCause: entitlementCause.copyWith(campaign: campaign));
    } else {
      return result;
    }
  }

  //getEntitlements
  Future<List<Entitlement>> getEntitlements() async {
    return await _entitlementsApi.getAllEntitlements();
  }

  Future<Entitlement> createEntitlement(
      String personId, String entitlementCauseId, List<EntitlementValue> values) async {
    return await _entitlementsApi.createEntitlement(
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
