import 'package:flutter/material.dart';

class OflBreadcrumb {
  final String header;
  final Function()? onTap;

  OflBreadcrumb(this.header, {this.onTap});
}

class BreadcrumbsRow extends StatelessWidget {
  const BreadcrumbsRow({super.key, required this.breadcrumbs});

  final List<OflBreadcrumb> breadcrumbs;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        //convert to map, to get access to current index
        ...breadcrumbs.asMap().entries.map((e) {
          int index = e.key;

          return breadcrumbItem(
            context,
            e.value,
            index == breadcrumbs.length - 1,
          );
        })
      ],
    );
  }

  Widget breadcrumbItem(BuildContext context, OflBreadcrumb breadcrumb, bool isLastItem) {
    TextTheme textTheme = Theme.of(context).textTheme;
    Widget child = Text(breadcrumb.header, style: textTheme.headlineSmall);

    return Row(
      children: [
        if (breadcrumb.onTap != null)
          InkWell(
            onTap: () {
              breadcrumb.onTap!();
            },
            child: child,
          )
        else
          child,
        if (!isLastItem) Text(' > ', style: textTheme.headlineSmall),
      ],
    );
  }
}
