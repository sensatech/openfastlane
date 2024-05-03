import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Widget centeredText(String text) {
  return Center(
    child: Text(text),
  );
}

Widget centeredErrorText(BuildContext context) {
  AppLocalizations lang = AppLocalizations.of(context)!;

  return Center(child: Text(lang.error_load_again));
}
