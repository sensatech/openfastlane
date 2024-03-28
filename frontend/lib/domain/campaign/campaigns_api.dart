import 'package:frontend/domain/abstract_api.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';

class CampaignsApi extends AbstractApi {
  CampaignsApi(super.dio);

  Future<List<Campaign>> getAllCampaigns() async {
    const $url = '/campaigns';
    return dioGetList($url, Campaign.fromJson);
  }

  Future<Campaign> getCampaign(String campaignId) async {
    final $url = '/campaigns/$campaignId';
    return dioGet($url, Campaign.fromJson);
  }
}
