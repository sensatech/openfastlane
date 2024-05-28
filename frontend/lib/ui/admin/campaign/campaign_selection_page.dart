import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/login/global_login_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/campaign/campaign_selection_content.dart';
import 'package:frontend/ui/admin/campaign/campaign_selection_vm.dart';
import 'package:frontend/ui/admin/commons/admin_content.dart';
import 'package:frontend/ui/admin/commons/admin_values.dart';
import 'package:frontend/ui/admin/commons/error_widget.dart';
import 'package:frontend/ui/admin/login/admin_login_page.dart';
import 'package:frontend/ui/commons/widgets/centered_progress_indicator.dart';
import 'package:frontend/ui/commons/widgets/ofl_breadcrumb.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';
import 'package:frontend/ui/commons/widgets/text_widgets.dart';
import 'package:go_router/go_router.dart';

class AdminCampaignSelectionPage extends StatelessWidget {
  const AdminCampaignSelectionPage({super.key});

  static const String routeName = 'admin-campaign-selection';
  static const String path = 'campaigns';

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;

    CampaignSelectionViewModel viewModel = sl<CampaignSelectionViewModel>();
    viewModel.loadCampaigns();

    return BlocListener<GlobalLoginService, GlobalLoginState>(
        listener: (BuildContext context, GlobalLoginState state) {
          if (state is NotLoggedIn) {
            GoRouter.of(context).goNamed(AdminLoginPage.routeName);
          }
        },
        child: OflScaffold(
          content: BlocBuilder<CampaignSelectionViewModel, CampaignSelectionState>(
            bloc: viewModel,
            builder: (context, state) {
              Widget child = const SizedBox();
              if (state is CampaignSelectionLoading) {
                child = centeredProgressIndicator();
              } else if (state is CampaignSelectionLoaded) {
                child = AdminCampaignSelectionContent(campaigns: state.campaigns);
              }  else if (state is CampaignSelectionError) {
                child = ErrorTextWidget(exception: state.error);
              } else {
                child = centeredText('');
              }

              return AdminContent(
                breadcrumbs: BreadcrumbsRow(breadcrumbs: [OflBreadcrumb(lang.select_campaign)]),
                width: smallContentWidth,
                child: child,
              );
            },
          ),
        ));
  }
}
