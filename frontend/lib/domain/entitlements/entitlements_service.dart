import 'package:frontend/domain/audit_item.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/campaign/campaigns_api.dart';
import 'package:frontend/domain/entitlements/consumption/consumption.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_api.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_possibility.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/entitlements/entitlement_value.dart';
import 'package:frontend/domain/entitlements/entitlements_api.dart';
import 'package:frontend/domain/person/persons_api.dart';
import 'package:frontend/domain/reports/download_file.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class EntitlementsService {
  EntitlementsService(this._entitlementsApi, this._personsApi, this._campaignsApi, this._consumptionApi);

  final EntitlementsApi _entitlementsApi;
  final PersonsApi _personsApi;
  final CampaignsApi _campaignsApi;
  final ConsumptionApi _consumptionApi;
  final Logger logger = getLogger();

  Future<Entitlement> getEntitlement(String id, {bool includeNested = false}) async {
    final result = await _entitlementsApi.getEntitlement(id);
    if (includeNested) {
      final person = await _personsApi.getPerson(result.personId);
      final entitlementCause = await _entitlementsApi.getEntitlementCause(result.entitlementCauseId);
      final campaign = await _campaignsApi.getCampaign(entitlementCause.campaignId);
      return result.copyWith(person: person, entitlementCause: entitlementCause.copyWith(campaign: campaign));
    } else {
      return result;
    }
  }

  Future<List<Entitlement>> getEntitlements() async {
    return await _entitlementsApi.getAllEntitlements();
  }

  Future<Entitlement> createEntitlement(
      String personId, String entitlementCauseId, List<EntitlementValue> values) async {
    return await _entitlementsApi.createEntitlement(
        personId: personId, entitlementCauseId: entitlementCauseId, values: values);
  }

  Future<void> updateEntitlement(String entitlementId, List<EntitlementValue> values) async {
    await _entitlementsApi.putEntitlement(entitlementId: entitlementId, values: values);
  }

  Future<List<EntitlementCause>> getEntitlementCauses() async {
    return await _entitlementsApi.getAllEntitlementCauses();
  }

  Future<EntitlementCause> getEntitlementCause(String id) async {
    return await _entitlementsApi.getEntitlementCause(id);
  }

  Future<List<Consumption>> getEntitlementConsumptions(String entitlementId) async {
    return await _consumptionApi.getEntitlementConsumptions(entitlementId);
  }

  Future<Consumption> getEntitlementConsumption(String entitlementId, String id) async {
    return await _consumptionApi.getEntitlementConsumption(entitlementId, id);
  }

  Future<List<Consumption>?> getConsumptions({
    String? personId,
    String? campaignId,
    String? causeId,
    String? from,
    String? to,
  }) async {
    return await _consumptionApi.findConsumptions(
      personId: personId,
      campaignId: campaignId,
      causeId: causeId,
      from: from,
      to: to,
    );
  }

  Future<List<Consumption>> getConsumptionsWithCampaignName({
    required String campaignId,
    String? personId,
    String? causeId,
    String? from,
    String? to,
  }) async {
    List<Consumption> consumptions = await _consumptionApi.findConsumptions(
      personId: personId,
      campaignId: campaignId,
      causeId: causeId,
      from: from,
      to: to,
    );

    List<Consumption> consumptionsWithCampaignName = [];
    Campaign campaign = await _campaignsApi.getCampaign(campaignId);
    String campaignName = campaign.name;

    for (Consumption consumption in consumptions) {
      consumptionsWithCampaignName.add(consumption.copyWith(campaignName: campaignName));
    }
    return consumptionsWithCampaignName;
  }

  Future<ConsumptionPossibility> canConsume(String entitlementId) async {
    return await _consumptionApi.canConsume(entitlementId);
  }

  Future<Consumption> performConsume(String entitlementId) async {
    return await _consumptionApi.performConsume(entitlementId);
  }

  Future<Entitlement> extend(String entitlementId) async {
    return await _entitlementsApi.extend(entitlementId);
  }

  Future<DownloadFile?> getQrPdf(String entitlementId) async {
    return await _entitlementsApi.getQrPdf(entitlementId);
  }

  Future<void> sendQrPdf(String entitlementId, String? recipient) async {
    return await _entitlementsApi.sendQrPdf(entitlementId, recipient);
  }

  Future<List<AuditItem>?> getAuditHistory(String entitlementId) async {
    try {
      return await _entitlementsApi.getAuditHistory(entitlementId);
    } on Exception catch (e) {
      logger.e('Error while fetching getAuditHistory for Entitlement $entitlementId: $e');
      return null;
    }
  }
}
