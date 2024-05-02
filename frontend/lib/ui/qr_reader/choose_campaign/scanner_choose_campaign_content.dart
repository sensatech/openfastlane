import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/setup/navigation/go_router.dart';
import 'package:frontend/setup/navigation/navigation_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:frontend/ui/qr_reader/choose_campaign/scanner_campaigns_vm.dart';

class ScannerCampaignContent extends StatelessWidget {
  const ScannerCampaignContent({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    NavigationService navigationService = sl<NavigationService>();

    ScannerCampaignsViewModel viewModel = sl<ScannerCampaignsViewModel>();
    viewModel.prepare();
    return BlocBuilder<ScannerCampaignsViewModel, ScannerCampaignsViewState>(
        bloc: viewModel,
        builder: (context, state) {
          if (state is ChooseCampaignInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChooseCampaignLoaded) {
            return Center(
              child: Column(
                children: [
                  largeVerticalSpacer(),
                  Text(lang.select_campaign, style: textTheme.headlineMedium!.copyWith(color: colorScheme.onPrimary)),
                  largeVerticalSpacer(),
                  Expanded(
                    child: SizedBox(
                      width: 300,
                      child: ListView.builder(
                        itemCount: state.campaigns.length,
                        itemBuilder: (context, index) {
                          Campaign campaign = state.campaigns[index];
                          return Padding(
                            padding: EdgeInsets.all(mediumPadding),
                            child: OflButton(
                              campaign.name,
                              () {
                                navigationService.pushNamedWithCampaignId(
                                  context,
                                  ScannerRoutes.scannerCamera.name,
                                  queryParameters: {'campaignId': campaign.id, 'checkOnly': 'true'},
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text(lang.error_load_again));
          }
        });
  }
}
