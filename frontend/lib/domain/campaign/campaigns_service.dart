import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/campaign/campaigns_api.dart';

class CampaignsService {
  CampaignsService(this._campaignsApi);
  final CampaignsApi _campaignsApi;

  Future<List<Campaign>> getCampaigns() async {
    return await _campaignsApi.getAllCampaigns();
  }

  Future<Campaign> getCampaign(String campaignId) async {
    return await _campaignsApi.getCampaign(campaignId);
  }
}
