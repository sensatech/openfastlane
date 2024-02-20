import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/login/global_login_service.dart';
import 'package:frontend/ui/admin/admin_values.dart';
import 'package:frontend/ui/admin/commons/admin_content.dart';
import 'package:frontend/ui/admin/login/admin_login_page.dart';
import 'package:frontend/ui/admin/person_list/admin_person_list_page.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';
import 'package:go_router/go_router.dart';

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  static const String routeName = 'admin';
  static const String path = '/admin';

  @override
  Widget build(BuildContext context) {
    return const AdminLoadingPage();
  }
}

class AdminLoadingPage extends StatelessWidget {
  const AdminLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    context.read<GlobalLoginService>().checkLoginStatus();
    return BlocConsumer<GlobalLoginService, GlobalLoginState>(
      listener: (context, state) {
        if (state is LoggedIn) {
          context.goNamed(AdminPersonListPage.routeName);
        } else if (state is NotLoggedIn) {
          context.goNamed(AdminLoginPage.routeName);
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
