import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/ui/admin/admin_values.dart';
import 'package:frontend/ui/admin/commons/admin_content.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_page.dart';
import 'package:frontend/ui/admin/persons/edit_person/edit_person_content.dart';
import 'package:frontend/ui/commons/widgets/ofl_breadcrumb.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';

class CreatePersonPage extends StatelessWidget {
  const CreatePersonPage({super.key});

  static const String routeName = 'create-person';
  static const String path = 'create';

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;

    return OflScaffold(
        content: AdminContent(
            breadcrumbs: BreadcrumbsRow(breadcrumbs: [
              OflBreadcrumb(lang.persons_view, AdminPersonListPage.routeName),
              OflBreadcrumb(lang.create_new_person, null)
            ]),
            width: smallContainerWidth,
            child: const EditPersonContent(person: null)));
  }
}
