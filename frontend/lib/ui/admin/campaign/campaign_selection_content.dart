import 'package:flutter/material.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/setup/navigation/navigation_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_page.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';

class AdminCampaignSelectionContent extends StatelessWidget {
  const AdminCampaignSelectionContent({super.key, required this.campaigns});

  final List<Campaign> campaigns;

  @override
  Widget build(BuildContext context) {
    NavigationService navigationService = sl<NavigationService>();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: largeSpace),
      child: Column(
        children: [
          ...campaigns.map((e) => Padding(
                padding: EdgeInsets.all(mediumPadding),
                child: SizedBox(
                    width: 300,
                    child: OflButton(e.name, () {
                      navigationService.updateCampaignId(e.id);
                      navigationService.goNamedWithCampaignId(context, AdminPersonListPage.routeName);
                    })),
              )),
        ],
      ),
    );
  }
}
