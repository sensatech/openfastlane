import 'package:flutter/material.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

double inputFieldWidth = 300;

// field can be either a form field, if entitlement is edited or created
// or a simple text widget if entitlement is viewed
Widget entitlementInfoRow(BuildContext context, String title, {required Widget field}) {
  TextTheme textTheme = Theme.of(context).textTheme;

  return Row(
    children: [
      SizedBox(
        width: inputFieldWidth,
        child: Text('$title:', style: textTheme.bodyMedium, textAlign: TextAlign.right),
      ),
      SizedBox(width: largeSpace),
      field,
    ],
  );
}

Widget entitlementInfoText(BuildContext context, String text) {
  TextTheme textTheme = Theme.of(context).textTheme;
  return Text(text, style: textTheme.bodyMedium, textAlign: TextAlign.right);
}
