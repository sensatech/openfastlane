import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AdminLoginContent extends StatelessWidget {
  const AdminLoginContent({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;

    return Center(
      child: Text(lang.login_page),
    );
  }
}
