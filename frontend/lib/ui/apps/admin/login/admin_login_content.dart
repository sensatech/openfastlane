import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/global_login_service.dart';
import 'package:frontend/ui/apps/admin/person_list/admin_person_list_page.dart';
import 'package:frontend/ui/commons/buttons.dart';
import 'package:frontend/ui/values/spacer.dart';
import 'package:go_router/go_router.dart';

class AdminLoginContent extends StatelessWidget {
  const AdminLoginContent({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;

    return Center(
      child: BlocConsumer<GlobalLoginService, GlobalLoginState>(
        listener: (context, state) {
          if (state is LoggedIn) {
            context.goNamed(AdminPersonListPage.routeName);
          }
        },
        builder: (context, state) {
          if (state is LoginLoading) {
            return Column(
              children: [
                const CircularProgressIndicator(),
                smallVerticalSpacer(),
                const Text('...du wirst angemeldet...'),
              ],
            );
          } else {
            return Column(
              children: [
                Text(lang.login_page),
                smallVerticalSpacer(),
                oflButton('login', () {
                  context.read<GlobalLoginService>().login();
                })
              ],
            );
          }
        },
      ),
    );
  }
}
