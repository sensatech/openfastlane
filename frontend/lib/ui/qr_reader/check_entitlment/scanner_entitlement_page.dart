import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/setup/navigation/go_router.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:frontend/ui/commons/widgets/scanner_scaffold.dart';
import 'package:frontend/ui/qr_reader/check_entitlment/scanner_entitlement_content.dart';
import 'package:frontend/ui/qr_reader/check_entitlment/scanner_entitlement_vm.dart';
import 'package:go_router/go_router.dart';

class ScannerEntitlementPage extends StatelessWidget {
  final bool? checkOnly;
  final String? entitlementId;
  final String? qrCode;

  const ScannerEntitlementPage({super.key, required this.checkOnly, required this.entitlementId, required this.qrCode});

  @override
  Widget build(BuildContext context) {
    // AppLocalizations lang = AppLocalizations.of(context)!;

    ScannerEntitlementViewModel viewModel = sl<ScannerEntitlementViewModel>();
    viewModel.prepare(entitlementId: entitlementId, qrCode: qrCode);

    bool canConsume = (checkOnly != null) ? !checkOnly! : false;
    logger.i('ScannerEntitlementPage: checkOnly=$checkOnly');

    // FIXME i18n
    return ScannerScaffold(
      title: 'Anspruch prüfen',
      content: BlocBuilder<ScannerEntitlementViewModel, ScannerEntitlementViewState>(
        bloc: viewModel,
        builder: (context, state) {
          if (state is ScannerEntitlementInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ScannerEntitlementLoaded) {
            // http://localhost:9080/#/admin/scanner/entitlements/65cb6c1851090750aaaaabbb0
            final entitlement = state.entitlement;
            final personId = state.entitlement.personId;
            return ScannerEntitlementContent(
              entitlement: entitlement,
              consumptions: state.consumptions,
              consumptionPossibility: state.consumptionPossibility,
              canConsume: canConsume,
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
