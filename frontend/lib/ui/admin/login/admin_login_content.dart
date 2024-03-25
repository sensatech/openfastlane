import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/login/global_login_service.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';

class AdminLoginContent extends StatelessWidget {
  const AdminLoginContent({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    GlobalLoginService globalLoginService = context.read<GlobalLoginService>();

    return Center(
      child: BlocBuilder<GlobalLoginService, GlobalLoginState>(
        bloc: globalLoginService,
        builder: (context, state) {
          if (state is LoginLoading) {
            return Padding(
              padding: EdgeInsets.all(mediumSpace),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(mediumSpace),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  smallVerticalSpacer(),
                  Text(lang.being_logged_in),
                ],
              ),
            );
          } else {
            return Padding(
              padding: EdgeInsets.all(mediumSpace),
              child: Column(
                children: [
                  Text(lang.please_login),
                  smallVerticalSpacer(),
                  OflButton(lang.login, () {
                    globalLoginService.login();
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
