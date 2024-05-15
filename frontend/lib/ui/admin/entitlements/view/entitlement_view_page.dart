import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/setup/navigation/navigation_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/commons/admin_content.dart';
import 'package:frontend/ui/admin/commons/admin_values.dart';
import 'package:frontend/ui/admin/entitlements/view/entitlement_view_content.dart';
import 'package:frontend/ui/admin/entitlements/view/entitlement_view_vm.dart';
import 'package:frontend/ui/admin/persons/person_view/admin_person_view_page.dart';
import 'package:frontend/ui/commons/widgets/breadcrumbs.dart';
import 'package:frontend/ui/commons/widgets/centered_progress_indicator.dart';
import 'package:frontend/ui/commons/widgets/ofl_breadcrumb.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';
import 'package:frontend/ui/commons/widgets/text_widgets.dart';

class EntitlementViewPage extends StatelessWidget {
  const EntitlementViewPage({super.key, required this.personId, required this.entitlementId});

  final String personId;
  final String entitlementId;

  static const String routeName = 'entitlement-view';

  //for some reason, if we remove "view" the navigation crashed and confuses it with create ...
  static const String path = ':personId/entitlements/:entitlementId/view';

  @override
  Widget build(BuildContext context) {
    EntitlementViewViewModel viewModel = sl<EntitlementViewViewModel>();
    NavigationService navigationService = sl<NavigationService>();

    viewModel.loadEntitlement(entitlementId);

    return OflScaffold(
      content: BlocBuilder<EntitlementViewViewModel, EntitlementViewState>(
          bloc: viewModel,
          builder: (context, state) {
            Widget child = centeredErrorText(context);
            String personName = '';
            String campaignName = '';

            if (state is EntitlementViewLoading) {
              child = centeredProgressIndicator();
            } else if (state is EntitlementViewLoaded) {
              EntitlementInfo entitlementInfo = state.entitlementInfo;
              personName = '${entitlementInfo.person.firstName} ${entitlementInfo.person.lastName}';
              campaignName = entitlementInfo.campaignName;
              child = EntitlementViewContent(
                entitlementInfo: state.entitlementInfo,
                validateEntitlement: () => viewModel.extendEntitlement(entitlementId),
                getQrPdf: () => viewModel.getQrPdf(entitlementId),
              );
            } else {
              child = centeredErrorText(context);
            }

            return AdminContent(
                breadcrumbs: BreadcrumbsRow(breadcrumbs: [
                  adminPersonListBreadcrumb(context),
                  OflBreadcrumb(personName, onTap: () {
                    navigationService.goNamedWithCampaignId(context, AdminPersonViewPage.routeName,
                        pathParameters: {'personId': personId});
                  }),
                  OflBreadcrumb(campaignName)
                ]),
                width: smallContainerWidth,
                child: child);
          }),
    );
  }
}
