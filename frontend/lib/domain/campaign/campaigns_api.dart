import 'package:frontend/domain/abstract_api.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';

class CampaignsApi extends AbstractApi {
  CampaignsApi(super.dio);

  Future<List<Campaign>> getAllCampaigns() async {
    const $url = '/campaigns';
    return dioGetList($url, Campaign.fromJson);

    /*// mock response, because there are no causes in the dummy campaigns on server
    List<Campaign> campaigns = [];
    try {
      logger.i('fetching all persons');
      // delay, so that the loading spinner is visible
      await Future.delayed(const Duration(milliseconds: 500));
      campaigns = mockedCampaigns.map((e) => Campaign.fromJson(e)).toList();
    } catch (e) {
      logger.e('error fetching all persons: $e');
    }
    return campaigns;*/
  }

  Future<Campaign> getCampaign(String campaignId) async {
    final $url = '/campaigns/$campaignId';
    return dioGet($url, Campaign.fromJson);
  }
}

final mockedCampaign = {
  "id": "65ef30e28fe3126b0c44affc",
  "name": "Campaign 1",
  "period": "YEARLY",
  "causes": [
    {
      "id": "65ef30e28fe3126b0c44affe",
      "campaignId": "65ef30e28fe3126b0c44afff",
      "criterias": [
        {"id": "65ef30e28fe3126b0c44b000", "name": "TEXT", "type": "TEXT"},
        {"id": "65ef30e28fe3126b0c44b001", "name": "CHECKBOX", "type": "CHECKBOX"},
        {"id": "65ef30e28fe3126b0c44b002", "name": "INTEGER", "type": "INTEGER"},
        {"id": "65ef30e28fe3126b0c44b003", "name": "OPTIONS", "type": "OPTIONS"},
        {"id": "65ef30e28fe3126b0c44b004", "name": "FLOAT", "type": "FLOAT"}
      ]
    },
    {
      "id": "65ef30e28fe3126b0c44b005",
      "campaignId": "65ef30e28fe3126b0c44b006",
      "criterias": [
        {"id": "65ef30e28fe3126b0c44b007", "name": "TEXT", "type": "TEXT"},
        {"id": "65ef30e28fe3126b0c44b008", "name": "CHECKBOX", "type": "CHECKBOX"},
        {"id": "65ef30e28fe3126b0c44b009", "name": "INTEGER", "type": "INTEGER"},
        {"id": "65ef30e28fe3126b0c44b00a", "name": "OPTIONS", "type": "OPTIONS"},
        {"id": "65ef30e28fe3126b0c44b00b", "name": "FLOAT", "type": "FLOAT"}
      ]
    }
  ]
};

final mockedCampaigns = [
  {
    "id": "65ef30e28fe3126b0c44affc",
    "name": "Campaign 1",
    "period": "YEARLY",
    "causes": [
      {
        "id": "65ef30e28fe3126b0c44affe",
        "campaignId": "65ef30e28fe3126b0c44afff",
        "criterias": [
          {"id": "65ef30e28fe3126b0c44b001", "name": "Jahreslohnzettel vorgelegt", "type": "CHECKBOX"},
          {"id": "65ef30e28fe3126b0c44b002", "name": "Personen im Haushalt", "type": "INTEGER"},
          {"id": "65ef30e28fe3126b0c44b004", "name": "Einkommen", "type": "FLOAT"},
          {"id": "65ef30e28fe3126b0c44b004", "name": "Einkommensart", "type": "OPTIONS"},
          {"id": "65ef30e28fe3126b0c44b000", "name": "Kommentar", "type": "TEXT"}
        ]
      },
      {
        "id": "65ef30e28fe3126b0c44b005",
        "campaignId": "65ef30e28fe3126b0c44b006",
        "criterias": [
          {"id": "65ef30e28fe3126b0c44b007", "name": "TEXT", "type": "TEXT"},
          {"id": "65ef30e28fe3126b0c44b008", "name": "CHECKBOX", "type": "CHECKBOX"},
          {"id": "65ef30e28fe3126b0c44b009", "name": "INTEGER", "type": "INTEGER"},
          {"id": "65ef30e28fe3126b0c44b00a", "name": "OPTIONS", "type": "OPTIONS"},
          {"id": "65ef30e28fe3126b0c44b00b", "name": "FLOAT", "type": "FLOAT"}
        ]
      }
    ]
  },
  {
    "id": "65ef30e28fe3126b0c44cccc",
    "name": "Campaign 2",
    "period": "YEARLY",
    "causes": [
      {
        "id": "65ef30e28fe3126b0c44afcc",
        "campaignId": "65ef30e28fe3126b0c44cccc",
        "criterias": [
          {"id": "65ef30e28fe3126b0c44b000", "name": "TEXT", "type": "TEXT"},
          {"id": "65ef30e28fe3126b0c44b0c1", "name": "CHECKBOX", "type": "CHECKBOX"},
          {"id": "65ef30e28fe3126b0c44b0c2", "name": "INTEGER", "type": "INTEGER"},
          {"id": "65ef30e28fe3126b0c44b0c3", "name": "OPTIONS", "type": "OPTIONS"},
          {"id": "65ef30e28fe3126b0c44b0c4", "name": "FLOAT", "type": "FLOAT"}
        ]
      },
      {
        "id": "65ef30e28fe3126b0c44b0dd",
        "campaignId": "65ef30e28fe3126b0c44cccc",
        "criterias": [
          {"id": "65ef30e28fe3126b0c44b00c7", "name": "TEXT", "type": "TEXT"},
          {"id": "65ef30e28fe3126b0c44b0c8", "name": "CHECKBOX", "type": "CHECKBOX"},
          {"id": "65ef30e28fe3126b0c44b0c9", "name": "INTEGER", "type": "INTEGER"},
          {"id": "65ef30e28fe3126b0c44b0ca", "name": "OPTIONS", "type": "OPTIONS"},
          {"id": "65ef30e28fe3126b0c44b0cb", "name": "FLOAT", "type": "FLOAT"}
        ]
      }
    ]
  }
];
