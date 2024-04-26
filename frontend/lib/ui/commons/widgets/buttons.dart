import 'package:flutter/material.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

class OflButton extends StatelessWidget {
  final String label;
  final Function onPressed;
  final Icon? icon;
  final Color? color;
  final Color? textColor;

  const OflButton(
    this.label,
    this.onPressed, {
    super.key,
    this.icon,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: () {
        onPressed();
      },
      child: Container(
        height: buttonHeight,
        decoration: BoxDecoration(
          color: (color != null) ? color : theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Padding(
          padding: EdgeInsets.all(mediumPadding),
          child: IntrinsicWidth(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null) ...[icon!, smallHorizontalSpacer()],
                Text(
                  label,
                  style: theme.textTheme.bodyMedium!
                      .copyWith(color: (textColor != null) ? textColor : theme.colorScheme.onSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
