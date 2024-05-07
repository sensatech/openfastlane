import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/scanner_scaffold.dart';
import 'package:frontend/ui/qr_reader/person_view/scanner_person_view_content.dart';
import 'package:frontend/ui/qr_reader/person_view/scanner_person_view_vm.dart';

class ScannerPersonViewPage extends StatelessWidget {
  final String personId;
  final String campaignId;

  const ScannerPersonViewPage({super.key, required this.personId, required this.campaignId});

  @override
  Widget build(BuildContext context) {
    // AppLocalizations lang = AppLocalizations.of(context)!;

    ScannerPersonViewModel viewModel = sl<ScannerPersonViewModel>();
    viewModel.prepare(personId: personId, campaignId: campaignId);
    return ScannerScaffold(
      content: BlocBuilder<ScannerPersonViewModel, ScannerPersonViewState>(
        bloc: viewModel,
        builder: (context, state) {
          if (state is ScannerPersonInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ScannerPersonLoaded) {
            return ScannerPersonViewContent(person: state.person, consumptions: state.consumptions);
          } else if (state is ScannerPersonNotFound) {
            return Padding(
              padding: EdgeInsets.all(mediumPadding),
              child: Center(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Person konnte nicht gefunden werden'),
                  Text('Fehler: ${state.error}'),
                ],
              )),
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
