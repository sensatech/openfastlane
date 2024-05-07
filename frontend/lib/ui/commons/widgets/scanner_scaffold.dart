import 'package:flutter/material.dart';
import 'package:frontend/domain/login/global_login_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

class ScannerScaffold extends StatelessWidget {
  const ScannerScaffold({super.key, required this.content, this.title, this.backgroundColor, this.onBack});

  final Widget content;
  final String? title;
  final Color? backgroundColor;
  final Function? onBack;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    GlobalLoginService loginService = sl<GlobalLoginService>();

    return Scaffold(
      appBar: AppBar(
        leading: (onBack != null)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () {
                  onBack!.call();
                },
              )
            : null,
        title: (title != null)
            ? Text(
                title!,
                style: TextStyle(color: colorScheme.onPrimary),
              )
            : null,
        actions: [
          // add logout button
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              loginService.logout();
            },
          )
        ],
        iconTheme: IconThemeData(
          color: colorScheme.onPrimary,
        ),
        backgroundColor: colorScheme.primary,
      ),
      backgroundColor: (backgroundColor != null) ? backgroundColor : colorScheme.onPrimary,
      body: content,
    );
  }

  Widget headerRow(BuildContext context, ColorScheme colorScheme) {
    return Padding(
        padding: EdgeInsets.all(smallPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', fit: BoxFit.contain, height: 50),
            largeHorizontalSpacer(),
          ],
        ));
  }
}
