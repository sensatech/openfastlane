import 'package:flutter/material.dart';
import 'package:frontend/ui/admin/admin_values.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/ofl_breadcrumb.dart';

class AdminContent extends StatelessWidget {
  const AdminContent(
      {super.key,
      required this.width,
      required this.child,
      this.customButton,
      this.breadcrumbs,
      this.showDivider = false});

  final double width;
  final Widget child;
  final BreadcrumbsRow? breadcrumbs;
  final Widget? customButton;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
        width: width,
        decoration: BoxDecoration(
          color: colorScheme.onPrimary,
          borderRadius: BorderRadius.all(Radius.circular(oflBorderRadius)),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(mediumSpace),
              child: SizedBox(
                height: adminHeaderHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (breadcrumbs != null) ...[breadcrumbs!] else const SizedBox(),
                    if (customButton != null) customButton!
                  ],
                ),
              ),
            ),
            if (showDivider) const Divider(),
            Expanded(child: child),
          ],
        ));
  }
}
