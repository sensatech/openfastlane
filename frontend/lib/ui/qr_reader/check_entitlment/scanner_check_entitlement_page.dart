import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/setup/go_router.dart';
import 'package:frontend/ui/commons/widgets/scanner_scaffold.dart';
import 'package:frontend/ui/qr_reader/check_entitlment/scanner_check_entitlement_vm.dart';
import 'package:frontend/ui/qr_reader/check_entitlment/scanner_entitlement_found_content.dart';
import 'package:go_router/go_router.dart';

import '../../../setup/setup_dependencies.dart';

class ScannerCheckEntitlementPage extends StatelessWidget {
  final bool readOnly;
  final String? entitlementId;
  final String? qrCode;

  const ScannerCheckEntitlementPage({super.key, required this.readOnly, required this.entitlementId, required this.qrCode});

  @override
  Widget build(BuildContext context) {
    // AppLocalizations lang = AppLocalizations.of(context)!;

    ScannerCheckEntitlementViewModel viewModel = sl<ScannerCheckEntitlementViewModel>();
    viewModel.prepare(readOnly: readOnly, entitlementId: entitlementId, qrCode: qrCode);

    return ScannerScaffold(
      title: 'Anspruch prüfen',
      content: BlocBuilder<ScannerCheckEntitlementViewModel, ScannerEntitlementViewState>(
        bloc: viewModel,
        builder: (context, state) {
          if (state is ScannerEntitlementInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ScannerEntitlementLoaded) {
            return ScannerEntitlementLoadedPage(
              entitlement: state.entitlement,
              readOnly: state.readOnly,
              onPersonClicked: () async {
                debugPrint("Person clicked");
                context.pushNamed(ScannerRoutes.scannerPerson.name, pathParameters: {'personId': '123'});
              },
              onConsumeClicked: viewModel.consume,
            );
          } else {
            return const Center(child: Text("Konnte nicht verarbeitet werden"));
          }
        },
      ),
    );
  }
}
