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
import 'package:go_router/go_router.dart';

class AdminPersonListPage extends StatefulWidget {
  const AdminPersonListPage({super.key, required this.campaignId});

  static const String routeName = 'admin-persons';
  static const String path = 'persons';

  final String campaignId;

  @override
  State<AdminPersonListPage> createState() => _AdminPersonListPageState();
}

class _AdminPersonListPageState extends State<AdminPersonListPage> {
  late TextEditingController searchController;
  late AdminPersonListViewModel viewModel;

  String _searchInput = '';

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    viewModel = sl<AdminPersonListViewModel>();
    viewModel.add(LoadAllPersonsWithEntitlementsEvent(campaignId: widget.campaignId));
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations lang = AppLocalizations.of(context)!;
    BreadcrumbsRow breadcrumbs = getBreadcrumbs(lang);

    return OflScaffold(
        content: AdminContent(
      width: largeContainerWidth,
      breadcrumbs: breadcrumbs,
      showDivider: true,
      customButton: OflButton(
        lang.create_new_person,
        () async {
          await context.pushNamed(CreatePersonPage.routeName);
          viewModel.add(LoadAllPersonsWithEntitlementsEvent(campaignId: widget.campaignId, searchQuery: _searchInput));
        },
        icon: Icon(Icons.add, color: theme.colorScheme.onSecondary),
      ),
      child: personListContent(context),
    ));
  }

  BreadcrumbsRow getBreadcrumbs(AppLocalizations lang) {
    return BreadcrumbsRow(
      breadcrumbs: [
        OflBreadcrumb(lang.persons_view),
      ],
    );
  }

  Widget personListContent(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;

    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(children: [
      personSearchHeader(colorScheme),
      BlocBuilder<AdminPersonListViewModel, AdminPersonListState>(
        bloc: viewModel,
        builder: (context, state) {
          if (state is AdminPersonListLoading) {
            return centeredProgressIndicator();
          } else if (state is AdminPersonListLoaded) {
            return AdminPersonListTable(
                persons: state.persons,
                campaignId: widget.campaignId,
                onPop: () {
                  viewModel.add(
                      LoadAllPersonsWithEntitlementsEvent(campaignId: widget.campaignId, searchQuery: _searchInput));
                });
          } else {
            return Center(child: Text(lang.an_error_occured));
          }
        },
      ),
    ]);
  }

  Row personSearchHeader(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        searchTextField(
          searchPersons: () {
            sl<AdminPersonListViewModel>()
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

  Padding searchTextField({required Function searchPersons}) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AppLocalizations lang = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.all(mediumPadding),
      child: SizedBox(
        width: 500,
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: lang.search_for_person,
            hintStyle: const TextStyle(fontSize: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(100),
              borderSide: const BorderSide(
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            filled: true,
            contentPadding: const EdgeInsets.all(16),
            fillColor: colorScheme.primaryContainer,
          ),
          onChanged: (value) {
            setState(() {
              _searchInput = value;
            });
            searchPersons();
          },
        ),
      ),
    );
  }
}
