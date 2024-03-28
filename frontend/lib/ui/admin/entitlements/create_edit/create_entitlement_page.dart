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
import 'package:frontend/ui/admin/entitlements/create_edit/create_or_edit_entitlement_content.dart';
import 'package:frontend/ui/admin/entitlements/create_edit/create_or_edit_entitlement_vm.dart';
import 'package:frontend/ui/admin/persons/person_view/admin_person_view_page.dart';
import 'package:frontend/ui/commons/values/ofl_custom_colors.dart';
import 'package:frontend/ui/commons/widgets/breadcrumbs.dart';
import 'package:frontend/ui/commons/widgets/ofl_breadcrumb.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

class CreateEntitlementPage extends StatelessWidget {
  const CreateEntitlementPage({super.key, required this.result, required this.personId});

  final String? personId;
  final Function(bool) result;

  static const String routeName = 'create-entitlement';
  static const String path = ':personId/entitlements/create';

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    CreateOrEditEntitlementViewModel viewModel = sl<CreateOrEditEntitlementViewModel>();
    GlobalUserService userService = sl<GlobalUserService>();
    Campaign? campaign = userService.currentCampaign;

    Widget child = const SizedBox();

    Logger logger = getLogger();
    if (personId != null && campaign != null) {
      viewModel.prepare(personId!, campaign.id);
    } else {
      logger.e('CreateEntitlementPage: person id is null - entitlement cannot be edited');
    }

    return OflScaffold(
      content: BlocConsumer<CreateOrEditEntitlementViewModel, CreateOrEditEntitlementState>(
        bloc: viewModel,
        listener: (context, state) {
          if (state is CreateOrEntitlementEdited) {
            customDialogBuilder(context, 'Anspruch erfolgreich angelegt', successColor);
          } else if (state is CreateOrEntitlementCompleted) {
            context.pop();
            result.call(true);
            context.pop();
          }
        },
        builder: (context, state) {
          String personName = '';
          String campaignName = '';

          if (state is CreateOrEditEntitlementLoading) {
            child = const Center(child: CircularProgressIndicator());
          } else if (state is CreateOrEditEntitlementLoaded) {
            child = CreateOrEditEntitlementContent(
              person: state.person,
              entitlementCauses: state.entitlementCauses,
              viewModel: viewModel,
            );
            personName = '${state.person.firstName} ${state.person.lastName}';
            campaignName = state.campaign.name;
          } else if (state is CreateOrEditEntitlementError) {
            child = Center(child: Text(lang.error_load_again));
          }

          return AdminContent(
              breadcrumbs: BreadcrumbsRow(breadcrumbs: [
                adminPersonListBreadcrumb(context),
                OflBreadcrumb(personName, onTap: () {
                  if (personId != null) {
                    context.goNamed(AdminPersonViewPage.routeName, pathParameters: {'personId': personId!});
                  }
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
