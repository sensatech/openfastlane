import 'package:flutter/material.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

class OflButton extends StatelessWidget {
  final String label;
  final Function? onPressed;
  final IconData? iconData;
  final Color? color;
  final Color? textColor;
  final Color? borderColor;

  const OflButton(this.label, this.onPressed, {super.key, this.iconData, this.color, this.textColor, this.borderColor});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Color backgroundColor = (color != null) ? color! : theme.colorScheme.secondary;
    Color contentColor = (textColor != null) ? textColor! : theme.colorScheme.onSecondary;

    return InkWell(
      onTap: onPressed != null ? () {
        onPressed!();
      } : null,
      child: Container(
        height: buttonHeight,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: (borderColor != null) ? borderColor! : Colors.transparent,
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: mediumPadding),
          child: IntrinsicWidth(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (iconData != null) ...[Icon(iconData!, color: contentColor), smallHorizontalSpacer()],
                Expanded(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium!.copyWith(color: contentColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
