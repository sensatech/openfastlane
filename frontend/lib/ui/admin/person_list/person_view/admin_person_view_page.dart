import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/admin_values.dart';
import 'package:frontend/ui/admin/commons/admin_content.dart';
import 'package:frontend/ui/admin/person_list/admin_person_list_page.dart';
import 'package:frontend/ui/admin/person_list/person_view/admin_person_view_content.dart';
import 'package:frontend/ui/admin/person_list/person_view/admin_person_view_vm.dart';
import 'package:frontend/ui/commons/widgets/ofl_breadcrumb.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';

class AdminPersonViewPage extends StatelessWidget {
  const AdminPersonViewPage({super.key, required this.personId});

  final String? personId;

  static const String routeName = 'admin-person-view';
  static const String path = ':personId';

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;

    AdminPersonViewViewModel viewModel = sl<AdminPersonViewViewModel>();
    if (personId != null) {
      viewModel.loadPerson(personId!);
    }

    return OflScaffold(
        content: BlocBuilder<AdminPersonViewViewModel, AdminPersonViewState>(
      bloc: viewModel,
      builder: (context, state) {
        Widget child = const SizedBox();
        String personName = '';

        if (state is PersonViewLoading) {
          child = const Center(child: CircularProgressIndicator());
        }
        if (state is PersonViewLoaded) {
          child = PersonViewContent(person: state.person);
          personName = '${state.person.firstName} ${state.person.lastName}';
        } else {
          child = Center(child: Text(lang.error_load_again));
        }

        return AdminContent(
            breadcrumbs: BreadcrumbsRow(breadcrumbs: [
              OflBreadcrumb(lang.persons_view, AdminPersonListPage.routeName),
              OflBreadcrumb(personName, null)
            ]),
            width: smallContainerWidth,
            child: Expanded(child: child));
      },
    ));
  }
}
