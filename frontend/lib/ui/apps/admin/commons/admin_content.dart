import 'package:flutter/material.dart';
import 'package:frontend/ui/apps/admin/admin_values.dart';
import 'package:frontend/ui/commons/ofl_breadcrumb.dart';
import 'package:frontend/ui/values/spacer.dart';

class AdminContent extends StatelessWidget {
  const AdminContent(
      {super.key, required this.width, required this.child, this.customButton, this.breadcrumbs});

  final double width;
  final Widget child;
  final BreadcrumbsRow? breadcrumbs;
  final Widget? customButton;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
          width: width,
          decoration: BoxDecoration(
            color: colorScheme.onPrimary,
            borderRadius: BorderRadius.all(Radius.circular(oflBorderRadius)),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(mediumSpace),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (breadcrumbs != null) ...[breadcrumbs!] else const SizedBox(),
                    if (customButton != null) customButton!
                  ],
                ),
              ),
              const Divider(),
              child,
            ],
          )),
    );
  }
}
