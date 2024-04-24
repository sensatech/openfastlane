import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/entitlements/entitlement_value.dart';
import 'package:frontend/setup/navigation/navigation_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/commons/admin_content.dart';
import 'package:frontend/ui/admin/commons/admin_values.dart';
import 'package:frontend/ui/admin/commons/custom_dialog_builder.dart';
import 'package:frontend/ui/admin/entitlements/create_edit/create_entitlement_vm.dart';
import 'package:frontend/ui/admin/entitlements/create_edit/create_or_edit_entitlement_content.dart';
import 'package:frontend/ui/admin/persons/person_view/admin_person_view_page.dart';
import 'package:frontend/ui/commons/values/ofl_custom_colors.dart';
import 'package:frontend/ui/commons/widgets/breadcrumbs.dart';
import 'package:frontend/ui/commons/widgets/ofl_breadcrumb.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';
import 'package:go_router/go_router.dart';

class CreateEntitlementPage extends StatelessWidget {
  const CreateEntitlementPage({super.key, required this.personId, required this.campaignId});

  final String personId;
  final String campaignId;

  static const String routeName = 'create-entitlement';
  static const String path = ':personId/entitlements/create';

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    CreateEntitlementViewModel viewModel = sl<CreateEntitlementViewModel>();
    NavigationService navigationService = sl<NavigationService>();
    Widget child = const SizedBox();

    viewModel.prepare(personId, campaignId);

    return OflScaffold(
      content: BlocConsumer<CreateEntitlementViewModel, CreateEntitlementState>(
        bloc: viewModel,
        listener: (context, state) {
          if (state is CreateEntitlementEdited) {
            customDialogBuilder(context, 'Anspruch erfolgreich angelegt', successColor);
          } else if (state is CreateEntitlementCompleted) {
            // pop twice - once for the dialog and once for the page
            context.pop();
            context.pop();
          }
        },
        builder: (context, state) {
          String personName = '';
          String campaignName = '';

          if (state is CreateEntitlementLoading) {
            child = const Center(child: CircularProgressIndicator());
          } else if (state is CreateEntitlementLoaded) {
            child = CreateOrEditEntitlementContent(
              person: state.person,
              entitlementCauses: state.entitlementCauses,
              createOrEditEntitlement: (String personId, String entitlementCauseId, List<EntitlementValue> values) {
                viewModel.createEntitlement(personId: personId, entitlementCauseId: entitlementCauseId, values: values);
              },
            );
            personName = '${state.person.firstName} ${state.person.lastName}';
            campaignName = state.campaign.name;
          } else if (state is CreateEditEntitlementError) {
            child = Center(child: Text(lang.error_load_again));
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
