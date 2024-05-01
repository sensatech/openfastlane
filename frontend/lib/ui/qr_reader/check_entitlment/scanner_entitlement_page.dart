import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:frontend/ui/commons/widgets/scanner_scaffold.dart';
import 'package:frontend/ui/qr_reader/check_entitlment/scanner_entitlement_content.dart';
import 'package:frontend/ui/qr_reader/check_entitlment/scanner_entitlement_vm.dart';

class ScannerEntitlementPage extends StatelessWidget {
  final bool? checkOnly;
  final String? entitlementId;
  final String? qrCode;

  const ScannerEntitlementPage({super.key, required this.checkOnly, required this.entitlementId, required this.qrCode});

  @override
  Widget build(BuildContext context) {
    ScannerEntitlementViewModel viewModel = sl<ScannerEntitlementViewModel>();
    viewModel.prepare(entitlementId: entitlementId);

    bool canConsume = (checkOnly != null) ? !checkOnly! : false;
    logger.i('ScannerEntitlementPage: checkOnly=$checkOnly');

    return ScannerScaffold(
      content: BlocBuilder<ScannerEntitlementViewModel, ScannerEntitlementViewState>(
        bloc: viewModel,
        builder: (context, state) {
          if (state is ScannerEntitlementInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ScannerEntitlementLoaded) {
            final entitlement = state.entitlement;
            return ScannerEntitlementContent(
              entitlement: entitlement,
              consumptions: state.consumptions,
              consumptionPossibility: state.consumptionPossibility,
              canConsume: canConsume,
              onConsumeClicked: viewModel.consume,
            );
          } else {
            return const Center(child: Text('Konnte nicht verarbeitet werden'));
          }
        },
      ),
    );
  }
}
