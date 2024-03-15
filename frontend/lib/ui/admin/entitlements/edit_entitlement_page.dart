import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/user/global_user_service.dart';
import 'package:frontend/setup/logger.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/commons/admin_content.dart';
import 'package:frontend/ui/admin/commons/admin_values.dart';
import 'package:frontend/ui/admin/commons/custom_dialog_builder.dart';
import 'package:frontend/ui/admin/entitlements/edit_entitlement_content.dart';
import 'package:frontend/ui/admin/entitlements/edit_entitlement_vm.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_page.dart';
import 'package:frontend/ui/admin/persons/person_view/admin_person_view_page.dart';
import 'package:frontend/ui/commons/values/ofl_custom_colors.dart';
import 'package:frontend/ui/commons/widgets/ofl_breadcrumb.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

class EditEntitlementPage extends StatelessWidget {
  const EditEntitlementPage({super.key, this.personId, this.entitlementId, required this.result});

  final String? personId;
  final String? entitlementId;
  final Function(bool) result;

  static const String routeName = 'edit-entitlement';
  static const String path = ':personId/entitlements/:entitlementId/edit';

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    EditEntitlementViewModel viewModel = sl<EditEntitlementViewModel>();
    GlobalUserService userService = sl<GlobalUserService>();
    Campaign? currentCampaign = userService.currentCampaign;

    Widget child = const SizedBox();

    Logger logger = getLogger();
    if (personId != null && entitlementId != null) {
      viewModel.prepareForEdit(personId!, entitlementId!);
    } else {
      logger.e('EditEntitlementPage: person id is null - person cannot be edited');
    }

    return OflScaffold(
      content: BlocConsumer<EditEntitlementViewModel, EditEntitlementState>(
        bloc: viewModel,
        listener: (context, state) {
          if (state is EntitlementEdited) {
            customDialogBuilder(context, 'Anspruch erfolgreich bearbeitet', successColor);
          } else if (state is EntitlementCompleted) {
            context.pop();
            result.call(true);
            context.pop();
          }
        },
        builder: (context, state) {
          String personName = '';

          if (state is EditEntitlementLoading) {
            child = const Center(child: CircularProgressIndicator());
          } else if (state is EditEntitlementLoaded) {
            child = EditEntitlementContent(
              person: state.person,
              entitlementCauses: state.entitlementCauses,
              viewModel: viewModel,
            );
            personName = '${state.person.firstName} ${state.person.lastName}';
          } else if (state is EditEntitlementError) {
            child = Center(child: Text(lang.error_load_again));
          }

          return AdminContent(
              breadcrumbs: BreadcrumbsRow(breadcrumbs: [
                OflBreadcrumb(lang.persons_view, onTap: () {
                  context.goNamed(AdminPersonListPage.routeName);
                }),
                OflBreadcrumb(personName, onTap: () {
                  if (personId != null) {
                    context.goNamed(AdminPersonViewPage.routeName, pathParameters: {'personId': personId!});
                  }
                }),
                OflBreadcrumb(currentCampaign?.name ?? 'Kampagne unbekannt'),
              ]),
              width: smallContainerWidth,
              child: child);
        },
      ),
    );
  }
}