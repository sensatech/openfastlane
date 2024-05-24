import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/login/global_login_service.dart';
import 'package:frontend/domain/user/global_user_service.dart';
import 'package:frontend/setup/navigation/go_router.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/admin_app.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:go_router/go_router.dart';

class OflScaffold extends StatelessWidget {
  const OflScaffold({super.key, required this.content});

  final Widget content;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    GlobalLoginService loginService = sl<GlobalLoginService>();
    loginService.checkLoginStatus();

    return SelectionArea(
        child: Scaffold(
      backgroundColor: colorScheme.primary,
      body: SingleChildScrollView(
        child: Column(
          children: [headerRow(context, loginService, colorScheme), largeVerticalSpacer(), content, largeVerticalSpacer()],
        ),
      ),
    ));
  }

  Widget headerRow(BuildContext context, GlobalLoginService loginService, ColorScheme colorScheme) {
    AppLocalizations lang = AppLocalizations.of(context)!;

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
                padding: EdgeInsets.all(mediumPadding),
                child: InkWell(
                    child: Image.asset('assets/logo.png'),
                    onTap: () {
                      context.goNamed(AdminApp.routeName);
                    }),
              ),
              OflButton(lang.title_scanner, () {
                context.pushNamed(ScannerRoutes.scanner.name);
              }),
            ],
          ),
          BlocBuilder<GlobalLoginService, GlobalLoginState>(
            bloc: loginService,
            builder: (context, state) {
              if (state is LoggedIn) {
                User? currentUser = loginService.currentUser;

                return Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, largeSpace, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(mediumPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (currentUser != null) Text(currentUser.username, style: Theme.of(context).textTheme.titleMedium),
                              if (currentUser != null) Text(currentUser.name, style: Theme.of(context).textTheme.bodyMedium),
                              if (currentUser != null) Text(currentUser.roles.join(', '), style: Theme.of(context).textTheme.bodyMedium)
                            ],
                          ),
                        ),
                        OflButton(lang.logout, () {
                          context.read<GlobalLoginService>().logout();
                        }),
                      ],
                    ));
              } else if (state is LoginLoading) {
                return Padding(padding: EdgeInsets.fromLTRB(0, 0, largeSpace, 0), child: const CircularProgressIndicator());
              } else if (state is NotLoggedIn) {
                return Padding(
                  padding: EdgeInsets.only(right: mediumPadding),
                  child: OflButton(lang.login, () {
                    context.read<GlobalLoginService>().login();
                  }),
                );
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
