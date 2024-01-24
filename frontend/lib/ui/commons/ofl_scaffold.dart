import 'package:flutter/material.dart';
import 'package:frontend/ui/values/spacer.dart';

class OflScaffold extends StatelessWidget {
  const OflScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Column(
        children: [
          headerRow(colorScheme),
          largeVerticalSpacer(),
          Expanded(
            child: Container(
                width: 1000,
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary,
                ),
                child: child),
          ),
          largeVerticalSpacer()
        ],
      ),
    );
  }

  Widget headerRow(ColorScheme colorScheme) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: colorScheme.onPrimary,
      ),
      child: Row(
        children: [
          largeHorizontalSpacer(),
          Padding(
            padding: EdgeInsets.all(smallSpace),
            child: Image.asset('assets/vhw_logo_not_formatted.png'),
          )
        ],
      ),
    );
  }
}
