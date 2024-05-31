import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/ui/admin/entitlements/view/entitlement_view_content.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:go_router/go_router.dart';

Future<void> showPromptDialog(
  BuildContext context, {
  required StringCallback onTap,
  required String title,
  required String body,
  required String submitText,
  required String? fieldValue,
  required String fieldHintText,
}) async {
  AppLocalizations lang = AppLocalizations.of(context)!;
  final TextEditingController controller = TextEditingController();
  controller.text = fieldValue ?? '';
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
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: fieldHintText,
                  labelText: fieldHintText,
                ),
              ),
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
                onTap(controller.text);
                context.pop();
              }),
            ],
          ),
        ],
      );
    },
  );
}
