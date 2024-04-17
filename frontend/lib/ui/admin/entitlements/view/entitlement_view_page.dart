import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
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

    if (entitlementId != null) {
      viewModel.loadEntitlement(entitlementId!);
    } else {
      logger.i('EntitlementViewPage: entitlement id is null ');
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
              EntitlementInfo entitlementInfo = state.entitlementInfo;

              Entitlement entitlement = entitlementInfo.entitlement;
              cause = entitlementInfo.cause;
              personName = '${entitlementInfo.person.firstName} ${entitlementInfo.person.lastName}';
              campaignName = entitlementInfo.campaignName;
              child = EntitlementViewContent(entitlement: entitlement, cause: cause);
            } else {
              child = centeredErrorText(context);
            }

            return AdminContent(
                breadcrumbs: BreadcrumbsRow(breadcrumbs: [
                  adminPersonListBreadcrumb(context),
                  OflBreadcrumb(personName, onTap: () {
                    if (personId != null) {
                      context.goNamed(AdminPersonViewPage.routeName, pathParameters: {'personId': personId!});
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
