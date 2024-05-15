import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/setup/navigation/navigation_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/commons/admin_content.dart';
import 'package:frontend/ui/admin/commons/admin_values.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_table.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_vm.dart';
import 'package:frontend/ui/admin/persons/create_person/create_person_page.dart';
import 'package:frontend/ui/admin/reports/admin_reports_page.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:frontend/ui/commons/widgets/centered_progress_indicator.dart';
import 'package:frontend/ui/commons/widgets/ofl_breadcrumb.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';
import 'package:frontend/ui/commons/widgets/person_search_text_field.dart';
import 'package:go_router/go_router.dart';

class AdminPersonListPage extends StatefulWidget {
  const AdminPersonListPage({super.key, this.campaignId});

  static const String routeName = 'admin-persons';
  static const String path = 'persons';

  final String? campaignId;

  @override
  State<AdminPersonListPage> createState() => _AdminPersonListPageState();
}

class _AdminPersonListPageState extends State<AdminPersonListPage> {
  late PersonListViewModel _viewModel;
  late TextEditingController _searchController;

  String _searchInput = '';

  @override
  void initState() {
    _viewModel = sl<PersonListViewModel>();
    _viewModel.add(LoadAllPersonsWithEntitlementsEvent(campaignId: widget.campaignId));
    _searchController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _viewModel.add(InitPersonListEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations lang = AppLocalizations.of(context)!;

    return OflScaffold(
        content: BlocBuilder<PersonListViewModel, PersonListState>(
      bloc: _viewModel,
      builder: (context, state) {
        String personsPageTitle = 'Alle Personen';

        if (state is PersonListLoaded && state.campaignName != null) {
          personsPageTitle = state.campaignName!;
        }

        BreadcrumbsRow breadcrumbs = getBreadcrumbs(personsPageTitle);

        return AdminContent(
          width: largeContainerWidth,
          breadcrumbs: breadcrumbs,
          showDivider: true,
          customButton: OflButton(
            lang.create_new_person,
            () async {
              await context.pushNamed(CreatePersonPage.routeName);
              _viewModel
                  .add(LoadAllPersonsWithEntitlementsEvent(campaignId: widget.campaignId, searchQuery: _searchInput));
            },
            icon: Icon(Icons.add, color: theme.colorScheme.onSecondary),
          ),
          child: personListContent(context, state),
        );
      },
    ));
  }

  BreadcrumbsRow getBreadcrumbs(String campaignName) {
    return BreadcrumbsRow(
      breadcrumbs: [
        OflBreadcrumb(campaignName),
      ],
    );
  }

  Widget personListContent(BuildContext context, PersonListState state) {
    AppLocalizations lang = AppLocalizations.of(context)!;

    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(children: [
      personSearchHeader(colorScheme),
      if (state is PersonListLoading || state is PersonListInitial)
        centeredProgressIndicator()
      else if (state is PersonListLoaded)
        AdminPersonListTable(
            persons: state.persons,
            campaignId: widget.campaignId,
            onPop: () {
              _viewModel
                  .add(LoadAllPersonsWithEntitlementsEvent(campaignId: widget.campaignId, searchQuery: _searchInput));
            })
      else
        Center(child: Text(lang.an_error_occured))
    ]);
  }

  Row personSearchHeader(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        PersonSearchTextField(
          controller: _searchController,
          updateSearchInput: (value) {
            setState(() {
              _searchInput = value;
            });
            _viewModel
                .add(LoadAllPersonsWithEntitlementsEvent(campaignId: widget.campaignId, searchQuery: _searchInput));
          },
        ),
        exportButton(context)
      ],
    );
  }

  Padding exportButton(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AppLocalizations lang = AppLocalizations.of(context)!;
    NavigationService navigationService = sl<NavigationService>();
    return Padding(
      padding: EdgeInsets.all(mediumPadding),
      child: TextButton(
          onPressed: () {
            navigationService.goNamedWithCampaignId(context, AdminReportsPage.routeName);
          },
          child: Row(
            children: [
              Icon(
                Icons.cloud_download_outlined,
                color: colorScheme.outline,
              ),
              smallHorizontalSpacer(),
              Text(
                lang.export_data,
                style: TextStyle(
                    color: colorScheme.outline,
                    decoration: TextDecoration.underline,
                    decorationColor: colorScheme.outline),
              )
            ],
          )),
    );
  }
}
