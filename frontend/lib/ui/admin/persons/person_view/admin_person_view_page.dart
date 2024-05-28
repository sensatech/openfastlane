import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/commons/admin_content.dart';
import 'package:frontend/ui/admin/commons/admin_values.dart';
import 'package:frontend/ui/admin/commons/error_widget.dart';
import 'package:frontend/ui/admin/persons/person_view/admin_person_view_content.dart';
import 'package:frontend/ui/admin/persons/person_view/admin_person_view_vm.dart';
import 'package:frontend/ui/commons/widgets/breadcrumbs.dart';
import 'package:frontend/ui/commons/widgets/centered_progress_indicator.dart';
import 'package:frontend/ui/commons/widgets/ofl_breadcrumb.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';

class AdminPersonViewPage extends StatelessWidget {
  const AdminPersonViewPage({super.key, required this.personId, this.campaignId});

  final String personId;
  final String? campaignId;

  static const String routeName = 'admin-person-view';
  static const String path = ':personId';

  @override
  Widget build(BuildContext context) {

    AdminPersonViewViewModel viewModel = sl<AdminPersonViewViewModel>();
    viewModel.loadPerson(personId, campaignId: campaignId);

    return OflScaffold(
        content: BlocBuilder<AdminPersonViewViewModel, AdminPersonViewState>(
      bloc: viewModel,
      builder: (context, state) {
        Widget child = const SizedBox();
        String personName = '';

        if (state is PersonViewLoading) {
          child = centeredProgressIndicator();
        } else if (state is PersonViewError) {
          child = ErrorTextWidget(exception: state.error);
        } else if (state is PersonViewLoaded) {
          child = PersonViewContent(
              person: state.person, campaign: state.campaign, entitlements: state.entitlements, audit: state.audit);
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
