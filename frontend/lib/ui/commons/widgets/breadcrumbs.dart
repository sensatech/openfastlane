import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_page.dart';
import 'package:frontend/ui/commons/widgets/ofl_breadcrumb.dart';
import 'package:go_router/go_router.dart';

OflBreadcrumb adminPersonListBreadcrumb(BuildContext context) {
  AppLocalizations lang = AppLocalizations.of(context)!;
  return OflBreadcrumb(lang.persons_view, onTap: () {
    context.goNamed(AdminPersonListPage.routeName);
  });
}
