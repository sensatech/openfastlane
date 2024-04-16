import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/domain/login/global_login_service.dart';
import 'package:frontend/setup/navigation/go_router.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/commons/values/color_schemes.g.dart';
import 'package:frontend/ui/commons/values/typography.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

class OflApp extends StatelessWidget {
  const OflApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    initializeDateFormatting();

    // usually we should not need that, maybe our routes are not well defined
    GoRouter.optionURLReflectsImperativeAPIs = true;

    final globalLoginService = sl<GlobalLoginService>();
    // globalLoginService.checkLoginStatus();

    return MultiBlocProvider(
      providers: [
        BlocProvider<GlobalLoginService>(create: (context) {
          return globalLoginService;
        }),
      ],
      child: MaterialApp.router(
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
      ),
    );
  }
}
