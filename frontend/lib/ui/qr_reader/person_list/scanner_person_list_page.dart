import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_vm.dart';
import 'package:frontend/ui/commons/widgets/scanner_scaffold.dart';
import 'package:frontend/ui/qr_reader/person_list/scanner_person_list_content.dart';

class ScannerPersonListPage extends StatelessWidget {
  const ScannerPersonListPage({super.key, required this.campaignId});

  final String? campaignId;

  @override
  Widget build(BuildContext context) {
    PersonListViewModel viewModel = sl<PersonListViewModel>();
    viewModel.add(LoadAllPersonsWithEntitlementsEvent(campaignId: campaignId));
    String? campaignName;
    List<Person> persons = [];
    return ScannerScaffold(
      content: BlocBuilder<PersonListViewModel, PersonListState>(
        bloc: viewModel,
        builder: (context, state) {
          //TODO: add other state cases
          if (state is PersonListLoaded) {
            campaignName = state.campaignName;
            persons = state.persons;
          }
          return ScannerPersonListContent(
              campaignName: campaignName,
              persons: persons,
              updateSearchInput: (value) =>
                  viewModel.add(LoadAllPersonsWithEntitlementsEvent(searchQuery: value, campaignId: campaignId)));
        },
      ),
    );
  }
}
