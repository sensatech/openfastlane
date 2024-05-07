import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/setup/navigation/navigation_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_vm.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/centered_progress_indicator.dart';
import 'package:frontend/ui/commons/widgets/person_search_text_field.dart';
import 'package:frontend/ui/commons/widgets/scanner_scaffold.dart';
import 'package:frontend/ui/commons/widgets/text_widgets.dart';
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
    viewModel.add(LoadAllPersonsWithEntitlementsEvent(campaignId: widget.campaignId));
    searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const SizedBox();
    AppLocalizations lang = AppLocalizations.of(context)!;
    NavigationService navigationService = sl<NavigationService>();

    String? campaignName;
    List<Person> persons = [];
    return ScannerScaffold(
      onBack: () => navigationService.goToCameraPage(context, widget.checkOnly),
      content: BlocBuilder<PersonListViewModel, PersonListState>(
        bloc: viewModel,
        builder: (context, state) {
          if (state is PersonListLoaded) {
            campaignName = state.campaignName;
            persons = state.persons;
            content = ScannerPersonListContent(
                campaignId: widget.campaignId,
                campaignName: campaignName,
                persons: persons,
                checkOnly: widget.checkOnly,
                updateSearchInput: (value) => viewModel
                    .add(LoadAllPersonsWithEntitlementsEvent(searchQuery: value, campaignId: widget.campaignId)));
          } else if (state is PersonListLoading) {
            content = centeredProgressIndicator();
          } else {
            content = centeredText(lang.error_load_again);
          }
          return SizedBox(
            width: double.infinity,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(mediumPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    mediumVerticalSpacer(),
                    if (campaignName != null) ...[
                      Text(campaignName!, style: Theme.of(context).textTheme.headlineMedium),
                      mediumVerticalSpacer()
                    ],
                    PersonSearchTextField(
                      controller: searchController,
                      updateSearchInput: (value) => viewModel
                          .add(LoadAllPersonsWithEntitlementsEvent(searchQuery: value, campaignId: widget.campaignId)),
                    ),
                    smallVerticalSpacer(),
                    content,
                    if (persons.isEmpty) centeredText('keine Person gefunden'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
