import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/user/global_user_serivce.dart';
import 'package:frontend/setup/logger.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/commons/admin_content.dart';
import 'package:frontend/ui/admin/commons/admin_values.dart';
import 'package:frontend/ui/admin/entitlements/edit_entitlement_content.dart';
import 'package:frontend/ui/admin/entitlements/edit_entitlement_vm.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_page.dart';
import 'package:frontend/ui/admin/persons/person_view/admin_person_view_page.dart';
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
    EditEntitlementViewModel viewModel = sl<EditEntitlementViewModel>();
    GlobalUserService userService = sl<GlobalUserService>();
    Campaign? currentCampaign = userService.currentCampaign;

    Logger logger = getLogger();
    if (personId != null) {
      viewModel.prepare(personId!);
    } else {
      logger.e('CreateEntitlementPage: person id is null - person cannot be edited');
    }

    return OflScaffold(
      content: BlocBuilder<EditEntitlementViewModel, EditEntitlementState>(
        bloc: viewModel,
        builder: (context, state) {
          Widget child = const SizedBox();
          String personName = '';

          if (state is EditEntitlementLoading) {
            child = const Center(child: CircularProgressIndicator());
          } else if (state is EditEntitlementLoaded) {
            child = EditEntitlementContent(
              personId: state.person.id,
              entitlementCauses: state.entitlementCauses,
            );

            personName = '${state.person.firstName} ${state.person.lastName}';
          } else {
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
