import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/login/global_login_service.dart';
import 'package:frontend/domain/user/global_user_serivce.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';

class OflScaffold extends StatelessWidget {
  const OflScaffold({super.key, required this.content});

  final Widget content;

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;
    Size sceenSize = MediaQuery.of(context).size;

    bool minScreenHeightReached = sceenSize.height < 600;
    bool minScreenWidthReached = sceenSize.width < 1000;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: SingleChildScrollView(
        child: Column(
          children: [
            headerRow(context, colorScheme),
            largeVerticalSpacer(),
            if (minScreenHeightReached || minScreenWidthReached)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(largeSpace),
                  child: Text(
                    lang.larger_screen_needed,
                    style: textTheme.headlineMedium!.copyWith(color: colorScheme.onPrimary),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              content,
            largeVerticalSpacer()
          ],
        ),
      ),
    );
  }

  Widget headerRow(BuildContext context, ColorScheme colorScheme) {
    AppLocalizations lang = AppLocalizations.of(context)!;

    GlobalLoginService loginService = context.read<GlobalLoginService>();

    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: colorScheme.onPrimary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              largeHorizontalSpacer(),
              Padding(
                padding: EdgeInsets.all(smallSpace),
                child: Image.asset('assets/vhw_logo_not_formatted.png'),
              )
            ],
          ),
          BlocBuilder<GlobalLoginService, GlobalLoginState>(
            bloc: loginService,
            builder: (context, state) {
              if (state is LoggedIn) {
                User? currentUser = sl<GlobalUserService>().currentUser;
                Campaign? currentCampaign = sl<GlobalUserService>().currentCampaign;

                return Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, largeSpace, 0),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(mediumSpace),
                          child: Column(
                            children: [
                              if (currentUser != null) Text(currentUser.username),
                              if (currentCampaign != null) Text(currentCampaign.name),
                            ],
                          ),
                        ),
                        oflButton(context, lang.logout, () {
                          context.read<GlobalLoginService>().logout();
                        }),
                      ],
                    ));
              } else if (state is LoginLoading) {
                return Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, largeSpace, 0), child: const CircularProgressIndicator());
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }
}
