import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/commons/admin_content.dart';
import 'package:frontend/ui/admin/commons/admin_values.dart';
import 'package:frontend/ui/admin/persons/edit_person/edit_person_content.dart';
import 'package:frontend/ui/admin/persons/edit_person/edit_person_vm.dart';
import 'package:frontend/ui/commons/widgets/breadcrumbs.dart';
import 'package:frontend/ui/commons/widgets/ofl_breadcrumb.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';

class EditPersonPage extends StatelessWidget {
  const EditPersonPage({super.key, required this.personId});

  final String personId;

  static const String routeName = 'edit-person';
  static const String path = ':personId/edit';

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;

    EditPersonViewModel viewModel = sl<EditPersonViewModel>();

    viewModel.prepare(personId);

    return OflScaffold(
        content: BlocBuilder<EditPersonViewModel, EditPersonState>(
      bloc: viewModel,
      builder: (context, state) {
        Widget child = const SizedBox();
        String personName = '';

        if (state is EditPersonLoading) {
          child = const Center(child: CircularProgressIndicator());
        } else if (state is EditPersonLoaded) {
          child = EditPersonContent(viewModel: viewModel, person: state.person);
          personName = '${state.person.firstName} ${state.person.lastName}';
        } else {
          child = Center(child: SelectableText(lang.error_load_again));
        }

        return AdminContent(
            breadcrumbs: BreadcrumbsRow(breadcrumbs: [
              adminPersonListBreadcrumb(context),
              OflBreadcrumb(personName),
              OflBreadcrumb(lang.edit_person)
            ]),
            width: smallContainerWidth,
            child: child);
      },
    ));
  }
}
