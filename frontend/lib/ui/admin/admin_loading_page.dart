import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/login/global_login_service.dart';
import 'package:frontend/ui/admin/commons/admin_content.dart';
import 'package:frontend/ui/admin/commons/admin_values.dart';
import 'package:frontend/ui/admin/login/admin_login_page.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';
import 'package:go_router/go_router.dart';

class AdminLoadingPage extends StatelessWidget {
  const AdminLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    context.read<GlobalLoginService>().checkLoginStatus();
    // GlobalUserService globalUserService = sl<GlobalUserService>();
    // Campaign? currentCampaign = globalUserService.currentCampaign;
    return BlocConsumer<GlobalLoginService, GlobalLoginState>(
      listener: (context, state) {
        if (state is LoggedIn) {
          // if (currentCampaign == null) {
          //   context.pushNamed(AdminCampaignSelectionPage.routeName);
          // } else {
          //   // never do that to users :)
          //   context.pushNamed(AdminPersonListPage.routeName);
          // }
        } else if (state is NotLoggedIn) {
          context.pushNamed(AdminLoginPage.routeName);
        }
      },
      builder: (context, state) {
        return OflScaffold(
          content: AdminContent(
            width: smallContainerWidth,
            child: Center(
              child: Text(lang.waiting_for_login),
            ),
          ),
        );
      },
    );
  }
}
