import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/setup/go_router.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/commons/widgets/scanner_scaffold.dart';
import 'package:frontend/ui/qr_reader/check_entitlment/scanner_check_entitlement_vm.dart';
import 'package:frontend/ui/qr_reader/check_entitlment/scanner_entitlement_found_content.dart';
import 'package:go_router/go_router.dart';

class ScannerCheckEntitlementPage extends StatelessWidget {
  final bool readOnly;
  final String? entitlementId;
  final String? qrCode;

  const ScannerCheckEntitlementPage(
      {super.key, required this.readOnly, required this.entitlementId, required this.qrCode});

  @override
  Widget build(BuildContext context) {
    // AppLocalizations lang = AppLocalizations.of(context)!;

    ScannerCheckEntitlementViewModel viewModel = sl<ScannerCheckEntitlementViewModel>();
    viewModel.prepare(readOnly: readOnly, entitlementId: entitlementId, qrCode: qrCode);

    // FIXME i18n
    return ScannerScaffold(
      title: 'Anspruch prüfen',
      content: BlocBuilder<ScannerCheckEntitlementViewModel, ScannerEntitlementViewState>(
        bloc: viewModel,
        builder: (context, state) {
          if (state is ScannerEntitlementInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ScannerEntitlementLoaded) {
            // http://localhost:9080/#/admin/scanner/entitlements/65cb6c1851090750aaaaabbb0
            final entitlement = state.entitlement;
            final personId = state.entitlement.personId;
            return ScannerEntitlementLoadedPage(
              entitlement: entitlement,
              consumptions: state.consumptions,
              consumptionPossibility: state.consumptionPossibility,
              readOnly: state.readOnly,
              onPersonClicked: () async {
                debugPrint('Person clicked');
                context.goNamed(ScannerRoutes.scannerPerson.name, pathParameters: {'personId': personId});
              },
              onConsumeClicked: viewModel.consume,
            );
          } else {
            // FIXME i18n

            return const Center(child: Text('Konnte nicht verarbeitet werden'));
          }
        },
      ),
    );
  }
}
