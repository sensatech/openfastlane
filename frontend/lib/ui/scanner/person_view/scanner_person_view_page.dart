import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/scanner_scaffold.dart';
import 'package:frontend/ui/scanner/person_view/scanner_person_view_content.dart';
import 'package:frontend/ui/scanner/person_view/scanner_person_view_vm.dart';

class ScannerPersonViewPage extends StatelessWidget {
  final String personId;
  final String campaignId;

  const ScannerPersonViewPage({super.key, required this.personId, required this.campaignId});

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;

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
                  Text(lang.person_not_found),
                  Text('${lang.error}: ${state.error}'),
                ],
              )),
            );
          } else {
            return Center(child: Text(lang.an_error_occured));
          }
        },
      ),
    );
  }
}
