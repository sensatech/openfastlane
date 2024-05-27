import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/setup/navigation/navigation_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/commons/admin_content.dart';
import 'package:frontend/ui/admin/commons/admin_values.dart';
import 'package:frontend/ui/admin/commons/error_widget.dart';
import 'package:frontend/ui/admin/entitlements/create_edit/create_or_edit_entitlement_content.dart';
import 'package:frontend/ui/admin/entitlements/create_edit/edit_entitlement_vm.dart';
import 'package:frontend/ui/admin/persons/person_view/admin_person_view_page.dart';
import 'package:frontend/ui/commons/custom_dialog_builder.dart';
import 'package:frontend/ui/commons/values/ofl_custom_colors.dart';
import 'package:frontend/ui/commons/widgets/breadcrumbs.dart';
import 'package:frontend/ui/commons/widgets/centered_progress_indicator.dart';
import 'package:frontend/ui/commons/widgets/ofl_breadcrumb.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';
import 'package:go_router/go_router.dart';

class EditEntitlementPage extends StatelessWidget {
  const EditEntitlementPage({super.key, required this.personId, required this.entitlementId});

  final String personId;
  final String entitlementId;

  static const String routeName = 'edit-entitlement';
  static const String path = ':personId/entitlements/:entitlementId/edit';

  @override
  Widget build(BuildContext context) {
    EditEntitlementViewModel viewModel = sl<EditEntitlementViewModel>();
    NavigationService navigationService = sl<NavigationService>();

    Widget child = const SizedBox();
    viewModel.prepareForEdit(personId, entitlementId);

    return OflScaffold(
      content: BlocConsumer<EditEntitlementViewModel, EditEntitlementState>(
        bloc: viewModel,
        listener: (context, state) {
          if (state is EntitlementEdited) {
            showAlertDialog(context, text: 'Anspruch erfolgreich bearbeitet', backgroundColor: successColor);
          } else if (state is EditEntitlementCompleted) {
            context.pop();
            context.pop();
          }
        },
        builder: (context, state) {
          String personName = '';
          String campaignName = '';

          if (state is ExistingEntitlementLoading) {
            child = centeredProgressIndicator();
          } else if (state is EditEntitlementError) {
            child = ErrorTextWidget(exception: state.exception);
          } else if (state is ExistingEntitlementLoaded) {
            child = CreateOrEditEntitlementContent(
              person: state.person,
              entitlementCauses: state.entitlementCauses,
              entitlement: state.entitlement,
              createOrEditEntitlement: (personId, entitlementCauseId, values) {
                viewModel.editEntitlement(entitlementId: entitlementId, values: values);
              },
            );
            personName = '${state.person.firstName} ${state.person.lastName}';
            campaignName = state.campaign.name;
          } else {
            child = const Center(child: Text(''));
          }

          return AdminContent(
              breadcrumbs: BreadcrumbsRow(breadcrumbs: [
                adminPersonListBreadcrumb(context),
                OflBreadcrumb(personName, onTap: () {
                  navigationService.goNamedWithCampaignId(context, AdminPersonViewPage.routeName,
                      pathParameters: {'personId': personId});
                }),
                OflBreadcrumb(campaignName),
              ]),
              width: smallContainerWidth,
              child: child);
        },
      ),
    );
  }
}
