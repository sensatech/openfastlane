import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/login/global_login_service.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

class ScannerScaffold extends StatelessWidget {
  const ScannerScaffold({super.key, required this.content, required this.title});

  final Widget content;
  final String title;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      backgroundColor: colorScheme.onPrimary,
      body: Container(
        alignment: Alignment.center,
        child: content,
      ),
    );
  }

  Widget headerRow(BuildContext context, ColorScheme colorScheme) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    GlobalLoginService loginService = context.read<GlobalLoginService>();

    return Padding(
        padding: EdgeInsets.all(smallSpace),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', fit: BoxFit.contain, height: 50),
            Container(width: 60),
          ],
        ));
  }
}
