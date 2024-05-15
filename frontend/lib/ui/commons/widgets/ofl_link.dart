import 'package:flutter/material.dart';

class OflLink extends StatelessWidget {
  final String label;
  final Function onPressed;
  final Icon? icon;
  final Color? color;

  const OflLink(this.label, this.onPressed, {super.key, this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return TextButton(
        onPressed: () async {
          onPressed();
        },
        child: Text(label,
            style: TextStyle(
              color: color ?? theme.colorScheme.secondary,
              decoration: TextDecoration.underline,
              decorationColor: color ?? theme.colorScheme.secondary,
            )));
  }
}
