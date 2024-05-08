import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/campaign/campaigns_api.dart';

class CampaignsService {
  CampaignsService(this._campaignsApi);

  final CampaignsApi _campaignsApi;

  Map<String, Campaign> _campaignsMap = {};

  Future<List<Campaign>> getCampaigns() async {
    if (_campaignsMap.isNotEmpty) {
      return _campaignsMap.values.toList();
    } else {
      List<Campaign> campaignsList = await _campaignsApi.getAllCampaigns();
      _campaignsMap = {for (var e in campaignsList) e.id: e};
      return await _campaignsApi.getAllCampaigns();
    }
  }

  Future<Campaign> getCampaign(String campaignId) async {
    if (_campaignsMap.containsKey(campaignId)) {
      return _campaignsMap[campaignId]!;
    } else {
      return await _campaignsApi.getCampaign(campaignId);
    }
  }

  void clearCache() {
    _campaignsMap = {};
  }
}
