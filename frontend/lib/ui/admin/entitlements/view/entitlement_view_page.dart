import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/user/global_user_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/commons/admin_content.dart';
import 'package:frontend/ui/admin/commons/admin_values.dart';
import 'package:frontend/ui/admin/entitlements/view/entitlement_view_content.dart';
import 'package:frontend/ui/admin/entitlements/view/entitlement_view_vm.dart';
import 'package:frontend/ui/admin/persons/person_view/admin_person_view_page.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:frontend/ui/commons/widgets/breadcrumbs.dart';
import 'package:frontend/ui/commons/widgets/ofl_breadcrumb.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';
import 'package:frontend/ui/commons/widgets/text_widgets.dart';
import 'package:go_router/go_router.dart';

class EntitlementViewPage extends StatelessWidget {
  const EntitlementViewPage({super.key, this.personId, this.entitlementId});

  final String? personId;
  final String? entitlementId;

  static const String routeName = 'entitlement-view';
  static const String path = ':personId/entitlements/:entitlementId/view';

  @override
  Widget build(BuildContext context) {
    EntitlementViewViewModel viewModel = sl<EntitlementViewViewModel>();
    GlobalUserService userService = sl<GlobalUserService>();
    Campaign? campaign = userService.currentCampaign;

    if (entitlementId != null && campaign != null) {
      viewModel.loadEntitlement(entitlementId!, campaign.id);
    } else {
      logger.i('EntitlementViewPage: entitlement id = $entitlementId or campaign id = ${campaign?.id}');
    }

    return OflScaffold(
      content: BlocBuilder<EntitlementViewViewModel, EntitlementViewState>(
          bloc: viewModel,
          builder: (context, state) {
            Widget child = centeredErrorText(context);
            String personName = '';
            String campaignName = '';
            EntitlementCause? cause;

            if (state is EntitlementViewLoading) {
              child = centeredProgressIndicator();
            } else if (state is EntitlementViewLoaded) {
              Entitlement entitlement = state.entitlement;
              Campaign campaign = state.campaign;
              cause = campaign.causes?.firstWhereOrNull((element) => element.id == entitlement.entitlementCauseId);
              personName = '${state.person.firstName} ${state.person.lastName}';
              campaignName = state.campaign.name;
              if (cause != null) {
                child = EntitlementViewContent(entitlement: entitlement, cause: cause);
              }
            } else {
              child = centeredErrorText(context);
            }

            return AdminContent(
                breadcrumbs: BreadcrumbsRow(breadcrumbs: [
                  adminPersonListBreadcrumb(context),
                  OflBreadcrumb(personName, onTap: () {
                    if (campaign != null && personId != null) {
                      context.goNamed(AdminPersonViewPage.routeName,
                          pathParameters: {'campaignId': campaign.id, 'personId': personId!});
                    }
                  }),
                  OflBreadcrumb(campaignName)
                ]),
                width: smallContainerWidth,
                child: child);
          }),
    );
  }
}
