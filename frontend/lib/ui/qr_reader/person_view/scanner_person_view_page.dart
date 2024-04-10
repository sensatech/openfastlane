import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/commons/widgets/scanner_scaffold.dart';
import 'package:frontend/ui/qr_reader/person_view/scanner_person_view_content.dart';
import 'package:frontend/ui/qr_reader/person_view/scanner_person_view_vm.dart';

class ScannerPersonViewPage extends StatelessWidget {
  final String personId;

  const ScannerPersonViewPage({super.key, required this.personId});

  @override
  Widget build(BuildContext context) {
    // AppLocalizations lang = AppLocalizations.of(context)!;

    ScannerPersonViewModel viewModel = sl<ScannerPersonViewModel>();
    viewModel.prepare(personId: personId);

    // FIXME i18n
    return ScannerScaffold(
      title: 'Person ansehen',
      content: BlocBuilder<ScannerPersonViewModel, ScannerPersonViewState>(
        bloc: viewModel,
        builder: (context, state) {
          if (state is ScannerPersonInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ScannerPersonLoaded) {
            return ScannerPersonViewContent(person: state.person, consumptions: state.consumptions);
          } else {
            // FIXME i18n
            return const Center(child: Text('Konnte nicht verarbeitet werden'));
          }
        },
      ),
    );
  }
}
