import 'package:flutter/material.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/user/global_user_serivce.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_page.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:go_router/go_router.dart';

class AdminCampaignSelectionContent extends StatelessWidget {
  const AdminCampaignSelectionContent({super.key, required this.campaigns});

  final List<Campaign> campaigns;

  @override
  Widget build(BuildContext context) {
    GlobalUserService globalUserService = sl<GlobalUserService>();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: largeSpace),
      child: Column(
        children: [
          ...campaigns.map((e) => Padding(
                padding: EdgeInsets.all(mediumSpace),
                child: SizedBox(
                    width: 300,
                    child: oflButton(context, e.name, () {
                      globalUserService.setCurrentCampaign(e);
                      context.goNamed(AdminPersonListPage.routeName);
                    })),
              )),
        ],
      ),
    );
  }
}
