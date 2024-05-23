import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/setup/navigation/navigation_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_vm.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/centered_progress_indicator.dart';
import 'package:frontend/ui/commons/widgets/person_search_text_field.dart';
import 'package:frontend/ui/commons/widgets/scanner_scaffold.dart';
import 'package:frontend/ui/commons/widgets/search_info.dart';
import 'package:frontend/ui/qr_reader/person_list/scanner_person_list_content.dart';

class ScannerPersonListPage extends StatefulWidget {
  const ScannerPersonListPage({super.key, required this.campaignId, this.checkOnly});

  final String? campaignId;
  final bool? checkOnly;

  @override
  State<ScannerPersonListPage> createState() => _ScannerPersonListPageState();
}

class _ScannerPersonListPageState extends State<ScannerPersonListPage> {
  late TextEditingController searchController;
  late PersonListViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = sl<PersonListViewModel>();
    viewModel.prepare(widget.campaignId);
    searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    NavigationService navigationService = sl<NavigationService>();

    return ScannerScaffold(
      content: SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(mediumPadding),
            child: BlocBuilder<PersonListViewModel, PersonListState>(
              bloc: viewModel,
              builder: (context, state) {
                String? campaignName = state.campaignName;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    mediumVerticalSpacer(),
                    if (campaignName != null) ...[
                      Text(campaignName, style: Theme.of(context).textTheme.headlineMedium),
                      mediumVerticalSpacer()
                    ],
                    PersonSearchTextField(
                      controller: searchController,
                      updateSearchInput: (value) =>
                          viewModel.add(LoadAllPersonsWithEntitlementsEvent(searchQuery: value)),
                    ),
                    smallVerticalSpacer(),
                    getContentForState(state, campaignName, lang),
                    // if (persons.isEmpty) centeredText(lang.no_person_found),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      onBack: () => navigationService.goToCameraPage(context, widget.checkOnly),
    );
  }

  Widget getContentForState(PersonListState state, String? campaignName, AppLocalizations lang) {
    if (state is PersonListLoaded) {
      return ScannerPersonListContent(
        campaignId: widget.campaignId,
        campaignName: campaignName,
        persons: state.persons,
        checkOnly: widget.checkOnly,
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(mediumPadding),
        child: Column(
          children: [
            if (state is PersonListLoading) centeredProgressIndicator(),
            if (state is PersonListTooMany)
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(lang.person_search_too_many, style: Theme.of(context).textTheme.titleMedium)),
            if (state is PersonListInitial) const SearchInfo(isInitial: true),
            if (state is PersonListEmpty) const SearchInfo(isInitial: false),
            if (state is PersonListError) Text(lang.an_error_occured),
          ],
        ),
      );
      // return centeredText(lang.error_load_again); );
    }
  }
}
