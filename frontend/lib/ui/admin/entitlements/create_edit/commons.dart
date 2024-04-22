import 'package:flutter/material.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

double inputFieldWidth = 300;

Widget criteriaSelectionRow(BuildContext context, String title, {required Widget field}) {
  TextTheme textTheme = Theme.of(context).textTheme;

  return Row(
    children: [
      SizedBox(
        width: inputFieldWidth,
        child: Text(title, style: textTheme.bodyMedium, textAlign: TextAlign.right),
      ),
      SizedBox(width: largeSpace),
      field,
    ],
  );
}
