import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/setup/go_router.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:frontend/ui/qr_reader/choose_campaign/scanner_campaigns_vm.dart';
import 'package:go_router/go_router.dart';

class ScannerCampaignContent extends StatelessWidget {
  const ScannerCampaignContent({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;

    ScannerCampaignsViewModel viewModel = sl<ScannerCampaignsViewModel>();
    viewModel.prepare();
    return BlocBuilder<ScannerCampaignsViewModel, ScannerCampaignsViewState>(
        bloc: viewModel,
        builder: (context, state) {
          if (state is ChooseCampaignInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChooseCampaignLoaded) {
            return Column(
              children: [
                const Text('Kampagne auswählen:'),
                Expanded(
                  child: ListView.builder(
                    itemCount: state.campaigns.length,
                    itemBuilder: (context, index) {
                      var campaign = state.campaigns[index];
                      return OflButton(
                        campaign.name,
                        () {
                          context.pushNamed(
                            ScannerRoutes.scannerCamera.name,
                            pathParameters: {'campaignId': campaign.id},
                            queryParameters: {'checkOnly': 'true'},
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            return Center(child: Text(lang.error_load_again));
          }
        });
  }
}
