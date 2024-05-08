import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/commons/admin_content.dart';
import 'package:frontend/ui/admin/commons/admin_values.dart';
import 'package:frontend/ui/admin/persons/person_view/admin_person_view_content.dart';
import 'package:frontend/ui/admin/persons/person_view/admin_person_view_vm.dart';
import 'package:frontend/ui/commons/widgets/breadcrumbs.dart';
import 'package:frontend/ui/commons/widgets/centered_progress_indicator.dart';
import 'package:frontend/ui/commons/widgets/ofl_breadcrumb.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';

class AdminPersonViewPage extends StatelessWidget {
  const AdminPersonViewPage({super.key, required this.personId});

  final String personId;

  static const String routeName = 'admin-person-view';
  static const String path = ':personId';

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;

    AdminPersonViewViewModel viewModel = sl<AdminPersonViewViewModel>();
    viewModel.loadPerson(personId);

    return OflScaffold(
        content: BlocBuilder<AdminPersonViewViewModel, AdminPersonViewState>(
      bloc: viewModel,
      builder: (context, state) {
        Widget child = const SizedBox();
        String personName = '';

        if (state is PersonViewLoading) {
          child = centeredProgressIndicator();
        } else if (state is PersonViewError) {
          child = Center(child: Text(lang.error_load_again));
        } else if (state is PersonViewLoaded) {
          child = PersonViewContent(person: state.person, entitlements: state.entitlements, audit: state.audit);
          personName = state.person.name;
        } else {
          child = centeredProgressIndicator();
        }

        return AdminContent(
            breadcrumbs: BreadcrumbsRow(breadcrumbs: [
              adminPersonListBreadcrumb(context),
              OflBreadcrumb(personName),
            ]),
            width: smallContainerWidth,
            child: child);
      },
    ));
  }
}
