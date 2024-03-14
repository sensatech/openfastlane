import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/campaign/campaign_selection_content.dart';
import 'package:frontend/ui/admin/campaign/campaign_selection_vm.dart';
import 'package:frontend/ui/admin/commons/admin_content.dart';
import 'package:frontend/ui/admin/commons/admin_values.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/ofl_breadcrumb.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';

class AdminCampaignSelectionPage extends StatelessWidget {
  const AdminCampaignSelectionPage({super.key});

  static const String routeName = 'admin-campaign-selection';
  static const String path = 'campaign_selection';

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;

    CampaignSelectionViewModel viewModel = sl<CampaignSelectionViewModel>();
    viewModel.loadCampaigns();

    return OflScaffold(
      content: BlocBuilder<CampaignSelectionViewModel, CampaignSelectionState>(
        bloc: viewModel,
        builder: (context, state) {
          Widget child = const SizedBox();
          if (state is CampaignSelectionLoading) {
            child = Padding(
              padding: EdgeInsets.all(mediumSpace),
              child: const Center(child: CircularProgressIndicator()),
            );
          } else if (state is CampaignSelectionLoaded) {
            child = AdminCampaignSelectionContent(campaigns: state.campaigns);
          } else {
            child = Center(child: Text(lang.error_load_again));
          }

          return AdminContent(
            breadcrumbs: BreadcrumbsRow(breadcrumbs: [OflBreadcrumb('Kampagne auswählen')]),
            width: smallContentWidth,
            child: child,
          );
        },
      ),
    );
  }
}
