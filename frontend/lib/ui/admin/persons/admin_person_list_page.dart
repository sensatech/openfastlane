import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/person/address/address_model.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/commons/admin_content.dart';
import 'package:frontend/ui/admin/commons/admin_values.dart';
import 'package:frontend/ui/admin/entitlements/create_entitlement_page.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_vm.dart';
import 'package:frontend/ui/admin/persons/create_person/create_person_page.dart';
import 'package:frontend/ui/admin/persons/edit_person/edit_person_page.dart';
import 'package:frontend/ui/admin/persons/person_view/admin_person_view_page.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:frontend/ui/commons/widgets/ofl_breadcrumb.dart';
import 'package:frontend/ui/commons/widgets/ofl_scaffold.dart';
import 'package:go_router/go_router.dart';

class AdminPersonListPage extends StatefulWidget {
  const AdminPersonListPage({super.key});

  static const String routeName = 'admin-persons';
  static const String path = 'persons';

  @override
  State<AdminPersonListPage> createState() => _AdminPersonListPageState();
}

class _AdminPersonListPageState extends State<AdminPersonListPage> {
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    AppLocalizations lang = AppLocalizations.of(context)!;
    BreadcrumbsRow breadcrumbs = getBreadcrumbs(lang);
    AdminPersonListViewModel viewModel = sl<AdminPersonListViewModel>();

    return OflScaffold(
        content: AdminContent(
      width: largeContainerWidth,
      breadcrumbs: breadcrumbs,
      showDivider: true,
      customButton: OflButton(
        lang.create_new_person,
        () async {
          context.pushNamed(CreatePersonPage.routeName, extra: (result) {
            if (result) {
              viewModel.loadAllPersons();
            }
          });
        },
        icon: Icon(Icons.add, color: theme.colorScheme.onSecondary),
      ),
      child: personListContent(context, viewModel),
    ));
  }

  BreadcrumbsRow getBreadcrumbs(AppLocalizations lang) {
    return BreadcrumbsRow(
      breadcrumbs: [
        OflBreadcrumb(lang.persons_view),
      ],
    );
  }

  Widget personListContent(BuildContext context, AdminPersonListViewModel viewModel) {
    AppLocalizations lang = AppLocalizations.of(context)!;

    viewModel.loadAllPersons();

    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Column(children: [
      personListHeaderRow(colorScheme),
      Table(
        columnWidths: personTableColumnWidths(),
        children: [tableHeaderRow(context)],
      ),
      BlocBuilder<AdminPersonListViewModel, AdminPersonListState>(
        bloc: viewModel,
        builder: (context, state) {
          if (state is AdminPersonListLoading) {
            return Center(
                child: Padding(padding: EdgeInsets.all(largeSpace), child: const CircularProgressIndicator()));
          } else if (state is AdminPersonListLoaded) {
            return Table(
              columnWidths: personTableColumnWidths(),
              children: [
                ...state.personsWithEntitlements.map((personWithEntitlements) =>
                    personTableRow(context, personWithEntitlements, state.campaignEntitlementCauses, viewModel)),
              ],
            );
          } else {
            return Center(child: Text(lang.an_error_occured));
          }
        },
      ),
    ]);
  }

  Map<int, TableColumnWidth> personTableColumnWidths() {
    return const {
      0: FlexColumnWidth(2),
      1: FlexColumnWidth(3),
      2: FlexColumnWidth(3),
      3: FlexColumnWidth(3),
      4: FlexColumnWidth(4),
      5: FlexColumnWidth(2),
      6: FlexColumnWidth(4),
      7: FlexColumnWidth(4),
    };
  }

  TableRow personTableRow(BuildContext context, PersonWithEntitlement personWithEntitlements,
      List<EntitlementCause> campaignEntitlementCauses, AdminPersonListViewModel viewModel) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AppLocalizations lang = AppLocalizations.of(context)!;
    Person person = personWithEntitlements.person;

    // FIXME
    // make that table sortable, orderable, clickable
    return TableRow(
      children: [
        customTableCell(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
                onPressed: () {
                  // FIXME create a navigator.viewPerson() for things like this
                  context.pushNamed(AdminPersonViewPage.routeName, pathParameters: {'personId': person.id});
                },
                icon: const Icon(Icons.remove_red_eye)),
            IconButton(
                onPressed: () async {
                  await context.pushNamed(EditPersonPage.routeName, pathParameters: {'personId': person.id});
                  viewModel.loadAllPersons();
                },
                icon: const Icon(Icons.edit))
          ],
        )),
        // TODO row should be clickable. Use DataTable or, i dont know, InkWells for this
        TableRowInkWell(
            child: Text(person.firstName),
            onTap: () {
              // FIXME create a navigator.viewPerson() for things like this
              context.pushNamed(AdminPersonViewPage.routeName, pathParameters: {'personId': person.id});
            }),
        customTableCell(child: Text(person.lastName)),
        customTableCell(child: Text(getFormattedDateAsString(context, person.dateOfBirth) ?? lang.invalid_date)),
        customTableCell(child: Text(person.address?.fullAddressAsString ?? lang.no_address_available)),
        customTableCell(child: Text(person.address?.postalCode ?? lang.no_address_available)),
        customTableCell(
            child: getEntitlementCellContent(
                context, person, personWithEntitlements.entitlements, campaignEntitlementCauses, viewModel)),
        customTableCell(
            child: TextButton(
                onPressed: () {},
                child: Text('leeres Feld',
                    style: TextStyle(color: colorScheme.secondary, decoration: TextDecoration.underline)))),
      ],
    );
  }

  Widget customTableCell({required Widget child}) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: SizedBox(
          height: 50,
          child: Align(
            alignment: Alignment.centerLeft,
            child: child,
          ),
        ),
      ),
    );
  }

  TableRow tableHeaderRow(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;

    return TableRow(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      children: [
        customTableCell(child: Checkbox(value: false, onChanged: (value) {})),
        customTableCell(child: headerText(lang.firstname)),
        customTableCell(child: headerText(lang.lastname)),
        customTableCell(child: headerText(lang.birthdate)),
        customTableCell(child: headerText(lang.address)),
        customTableCell(child: headerText(lang.zip)),
        customTableCell(child: headerText(lang.last_collection)),
        customTableCell(child: headerText(lang.valid_until))
      ],
    );
  }

  Text headerText(String label) => Text(label, style: const TextStyle(fontWeight: FontWeight.bold));

  Row personListHeaderRow(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [searchTextField(context), exportButton(context)],
    );
  }

  Padding exportButton(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AppLocalizations lang = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.all(mediumPadding),
      child: TextButton(
          onPressed: () {},
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

  Padding searchTextField(BuildContext context) {
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
        ),
      ),
    );
  }

  Entitlement? getPersonEntitlement(
      Person person, List<Entitlement> personEntitlements, List<EntitlementCause> entitlementCauses) {
    Entitlement? personEntitlement = personEntitlements.firstWhereOrNull(
        (entitlement) => entitlementCauses.any((cause) => cause.id == entitlement.entitlementCauseId));
    return personEntitlement;
  }

  Widget getEntitlementCellContent(BuildContext context, Person person, List<Entitlement> entitlements,
      List<EntitlementCause> campaignEntitlementCauses, AdminPersonListViewModel viewModel) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    Entitlement? entitlement = getPersonEntitlement(person, entitlements, campaignEntitlementCauses);

    if (entitlement == null) {
      return TextButton(
          onPressed: () async {
            await context.pushNamed(CreateEntitlementPage.routeName,
                pathParameters: {'personId': person.id}, extra: (result) {});
            // FIXME: find a way to refresh the list after creating a new entitlement, WITHOUT creating difficult URLs
            viewModel.loadAllPersons();
          },
          child: Text(lang.create_entitlement,
              style: TextStyle(color: colorScheme.secondary, decoration: TextDecoration.underline)));
    } else {
      return TextButton(
          onPressed: () {},
          child: Text(entitlement.id,
              style: TextStyle(color: colorScheme.secondary, decoration: TextDecoration.underline)));
    }
  }
}
