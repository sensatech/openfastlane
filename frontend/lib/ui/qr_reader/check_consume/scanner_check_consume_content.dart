import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/qr_reader/check_consume/camera_widget.dart';
import 'package:frontend/ui/qr_reader/choose_campaign/scanner_campaigns_vm.dart';

class ScannerCheckConsumeContent extends StatelessWidget {
  const ScannerCheckConsumeContent({super.key});

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
            return const Column(
              children: [
                Text("CameraWidget:"),
                Expanded(
                  child: CameraWidget(),
                ),
              ],
            );
          } else {
            return Center(child: Text(lang.error_load_again));
          }
        });
  }
}
