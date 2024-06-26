import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/commons/admin_content.dart';
import 'package:frontend/ui/admin/commons/admin_values.dart';
import 'package:frontend/ui/admin/persons/edit_person/edit_or_create_person_content.dart';
import 'package:frontend/ui/admin/persons/edit_person/edit_person_vm.dart';
import 'package:frontend/ui/commons/widgets/breadcrumbs.dart';
import 'package:frontend/ui/commons/widgets/ofl_breadcrumb.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';

class CreatePersonPage extends StatelessWidget {
  const CreatePersonPage({super.key});

  static const String routeName = 'create-person';
  static const String path = 'create';

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;

    final viewModel = sl<EditOrCreatePersonViewModel>();
    return OflScaffold(
        content: AdminContent(
            breadcrumbs: BreadcrumbsRow(
                breadcrumbs: [adminPersonListBreadcrumb(context), OflBreadcrumb(lang.create_new_person)]),
            width: smallContainerWidth,
            child: EditOrCreatePersonContent(
              viewModel: viewModel,
              person: null,
            )));
  }
}
