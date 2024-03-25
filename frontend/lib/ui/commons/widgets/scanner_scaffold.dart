import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/login/global_login_service.dart';
import 'package:frontend/domain/user/global_user_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';

class ScannerScaffold extends StatelessWidget {
  const ScannerScaffold({super.key, required this.content});

  final Widget content;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Container(
        alignment: Alignment.center,
        width: 800,
        child: Column(
          children: [
            headerRow(context, colorScheme),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: content,
              ),
            ),
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
      decoration: BoxDecoration(color: colorScheme.onPrimary),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.all(smallSpace),
                child: const Text("logo"),
              )
            ],
          ),
          BlocBuilder<GlobalLoginService, GlobalLoginState>(
            bloc: loginService,
            builder: (context, state) {
              if (state is LoggedIn) {
                User? currentUser = sl<GlobalUserService>().currentUser;
                return Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, largeSpace, 0),
                    child: Row(
                      children: [
                        if (currentUser != null)
                          Padding(
                            padding: EdgeInsets.all(mediumSpace),
                            child: SelectableText(sl<GlobalUserService>().currentUser!.username),
                          ),
                        OflButton(lang.logout, () {
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
