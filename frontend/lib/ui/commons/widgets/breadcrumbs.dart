import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/setup/navigation/navigation_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_page.dart';
import 'package:frontend/ui/commons/widgets/ofl_breadcrumb.dart';

OflBreadcrumb adminPersonListBreadcrumb(BuildContext context) {
  AppLocalizations lang = AppLocalizations.of(context)!;
  NavigationService navigationService = sl<NavigationService>();
  return OflBreadcrumb(lang.persons_view, onTap: () {
    navigationService.goNamedWithCampaignId(context, AdminPersonListPage.routeName);
  });
}
