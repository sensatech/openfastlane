import 'package:flutter/material.dart';
import 'package:frontend/ui/commons/values/spacer.dart';

Widget oflButton(
  BuildContext context,
  String label,
  Function onPressed, {
  Icon? icon,
}) {
  ThemeData theme = Theme.of(context);

  return InkWell(
    onTap: () {
      onPressed();
    },
    child: Container(
      height: 50,
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Padding(
        padding: EdgeInsets.all(mediumSpace),
        child: IntrinsicWidth(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[icon, smallHorizontalSpacer()],
              Text(
                label,
                style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onSecondary),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
