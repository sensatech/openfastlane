import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:go_router/go_router.dart';

Future<void> showConfirmDialog(
  BuildContext context, {
  required Function onTap,
  String title = '',
  String body = '',
  String submitText = '',
}) async {
  AppLocalizations lang = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(body),
            ],
          ),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OflButton(
                lang.cancel,
                () {
                  context.pop();
                },
                color: Colors.transparent,
                textColor: Colors.black,
              ),
              OflButton(submitText, () {
                context.pop();
                onTap();
              }),
            ],
          ),
        ],
      );
    },
  );
}
