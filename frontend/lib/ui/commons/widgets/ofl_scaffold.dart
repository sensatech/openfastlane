import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/login/global_login_service.dart';
import 'package:frontend/ui/commons/values/spacer.dart';
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
      body: Column(
        children: [
          headerRow(context, colorScheme),
          largeVerticalSpacer(),
          if (minScreenHeightReached || minScreenWidthReached)
            Expanded(
                child: Center(
              child: Padding(
                padding: EdgeInsets.all(largeSpace),
                child: Text(
                  lang.larger_screen_needed,
                  style: textTheme.headlineMedium!.copyWith(color: colorScheme.onPrimary),
                  textAlign: TextAlign.center,
                ),
              ),
            ))
          else
            Expanded(child: content),
          largeVerticalSpacer()
        ],
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
                return Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, largeSpace, 0),
                    child: oflButton(context, lang.logout, () {
                      context.read<GlobalLoginService>().logout();
                    }));
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
