import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/setup/go_router.dart';
import 'package:frontend/ui/values/color_schemes.g.dart';
import 'package:frontend/ui/values/typography.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OpenFastLane Flutter App',
      theme: ThemeData(colorScheme: lightColorScheme, useMaterial3: true, textTheme: textTheme),
      darkTheme: ThemeData(colorScheme: darkColorScheme, useMaterial3: true, textTheme: textTheme),
      themeMode: ThemeMode.light,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de'), // German
      ],
      routerConfig: router,
    );
  }
}
