import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/ui/admin/commons/admin_content.dart';
import 'package:frontend/ui/admin/commons/admin_values.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key, this.message});

  static const String routeName = 'admin-not-found';
  static const String path = '404';

  final String? message;

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    return OflScaffold(
        content: AdminContent(
      width: smallContainerWidth,
      child: Padding(
          padding: EdgeInsets.symmetric(vertical: largeSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(lang.route_not_found),
              if (message != null) Text(message!),
            ],
          )),
    ));
  }
}
