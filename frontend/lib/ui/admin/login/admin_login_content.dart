import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/login/global_login_service.dart';
import 'package:frontend/setup/navigation/navigation_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/campaign/campaign_selection_page.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_page.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:frontend/ui/commons/widgets/centered_progress_indicator.dart';

class AdminLoginContent extends StatelessWidget {
  const AdminLoginContent({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    GlobalLoginService globalLoginService = context.read<GlobalLoginService>();
    NavigationService navigationService = sl<NavigationService>();

    return Center(
      child: BlocConsumer<GlobalLoginService, GlobalLoginState>(
        bloc: globalLoginService,
        listener: (BuildContext context, GlobalLoginState state) {
          if (state is LoggedIn) {
            navigationService.goNamedWithCampaignId(context, AdminCampaignSelectionPage.routeName);
          }
        },
        builder: (context, state) {
          if (state is LoginLoading) {
            return Padding(
              padding: EdgeInsets.all(mediumPadding),
              child: Column(
                children: [
                  centeredProgressIndicator(),
                  smallVerticalSpacer(),
                  Text(lang.being_logged_in),
                ],
              ),
            );
          } else if (state is LoggedIn) {
            return Padding(
              padding: EdgeInsets.all(mediumPadding),
              child: Column(
                children: [
                  centeredProgressIndicator(),
                ],
              ),
            );
          } else {
            return Padding(
              padding: EdgeInsets.all(mediumPadding),
              child: Column(
                children: [
                  Text(lang.please_login),
                  smallVerticalSpacer(),
                  OflButton(lang.login, () async {
                    await globalLoginService.login();
                  })
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
