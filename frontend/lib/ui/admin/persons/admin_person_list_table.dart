import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/person/address/address_model.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/entitlements/create_entitlement_page.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_vm.dart';
import 'package:frontend/ui/admin/persons/edit_person/edit_person_page.dart';
import 'package:frontend/ui/admin/persons/person_view/admin_person_view_page.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:go_router/go_router.dart';

class AdminPersonListTable extends StatefulWidget {
  final List<PersonWithEntitlement> personsWithEntitlements;

  final List<EntitlementCause> campaignEntitlementCauses;

  const AdminPersonListTable({
    super.key,
    required this.personsWithEntitlements,
    required this.campaignEntitlementCauses,
  });

  @override
  State<AdminPersonListTable> createState() => _AdminPersonListPageState();
}

class _AdminPersonListPageState extends State<AdminPersonListTable> {
  int? sortColumnIndex;
  bool sortAscending = true;

  List<PersonWithEntitlement> currentSortedData = [];

  @override
  void initState() {
    super.initState();
    sortColumnIndex = null;

    currentSortedData = widget.personsWithEntitlements;
  }

  void rebuildTable() {
    setState(() {
      currentSortedData.sort((a, b) {
        Person first = a.person;
        Person second = b.person;

        int result = 0;
        switch (sortColumnIndex) {
          case 1:
            result = first.firstName.compareTo(second.firstName);
            break;
          case 2:
            result = first.lastName.compareTo(second.lastName);
            break;
          // FIXME do the rest, dateOfBirth as date, plz text, address streetname
          default:
            result = first.lastName.compareTo(second.lastName);
        }

        if (sortAscending) {
          return result;
        } else {
          return result * (-1);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    AdminPersonListViewModel viewModel = sl<AdminPersonListViewModel>();
    return DataTable(
      sortColumnIndex: sortColumnIndex,
      sortAscending: sortAscending,
      columns: personTableColumns(context),
      rows: [
        ...currentSortedData.map((personWithEntitlements) => personTableRow(
              context,
              personWithEntitlements,
              widget.campaignEntitlementCauses,
              viewModel,
            ))
      ],
    );
  }

  DataRow personTableRow(
    BuildContext context,
    PersonWithEntitlement personWithEntitlements,
    List<EntitlementCause> entitlementCauses,
    AdminPersonListViewModel viewModel,
  ) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    AppLocalizations lang = AppLocalizations.of(context)!;
    Person person = personWithEntitlements.person;
    List<Entitlement> personEntitlements = personWithEntitlements.entitlements;

    // FIXME
    // make that table sortable, orderable, clickable
    return DataRow(
      cells: [
        DataCell(Row(
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
        DataCell(Text(person.firstName), onTap: () {
          // FIXME create a navigator.viewPerson() for things like this
          context.pushNamed(AdminPersonViewPage.routeName, pathParameters: {'personId': person.id});
        }),
        DataCell(Text(person.lastName)),
        DataCell(Text(getFormattedDateAsString(context, person.dateOfBirth) ?? lang.invalid_date)),
        DataCell(Text(person.address?.fullAddressAsString ?? lang.no_address_available)),
        DataCell(Text(person.address?.postalCode ?? lang.no_address_available)),
        DataCell(getEntitlementCellContent(context, person, personEntitlements, entitlementCauses, viewModel)),
        DataCell(TextButton(
            onPressed: () {},
            child: Text('', style: TextStyle(color: colorScheme.secondary, decoration: TextDecoration.underline)))),
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

  void onSortClicked(int columnIndex, bool ascending) {
    sortColumnIndex = columnIndex;
    sortAscending = ascending;
    rebuildTable();
  }

  List<DataColumn> personTableColumns(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;

    return [
      DataColumn(label: Expanded(child: Checkbox(value: false, onChanged: (value) {})), onSort: onSortClicked),
      DataColumn(label: headerText(lang.firstname), onSort: onSortClicked),
      DataColumn(label: headerText(lang.lastname), onSort: onSortClicked),
      DataColumn(label: headerText(lang.birthdate), onSort: onSortClicked),
      DataColumn(label: headerText(lang.address), onSort: onSortClicked),
      DataColumn(label: headerText(lang.zip), onSort: onSortClicked),
      DataColumn(label: headerText(lang.last_collection), onSort: onSortClicked),
      DataColumn(label: headerText(lang.valid_until), onSort: onSortClicked)
    ];
  }

  Expanded headerText(String label) =>
      Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)));

  Entitlement? getPersonEntitlement(
    Person person,
    List<Entitlement> personEntitlements,
    List<EntitlementCause> entitlementCauses,
  ) {
    // FIXME: please what?
    // the entitlement of a person is the first entitlement, which is an entitlement which has its entitlementCauseId?
    Entitlement? personEntitlement = personEntitlements.firstWhereOrNull(
        (entitlement) => entitlementCauses.any((cause) => cause.id == entitlement.entitlementCauseId));
    return personEntitlement;
  }

  Widget getEntitlementCellContent(
    BuildContext context,
    Person person,
    // FIXME:
    List<Entitlement> personEntitlements,
    List<EntitlementCause> entitlementCauses,
    // todo: usually, for that you would not pass the VM, but the function
    AdminPersonListViewModel viewModel,
  ) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    // FIXME: we really need to fix this, this is not a UI task.
    // the VM should prepare the data to be used, e.g. PersonWithEntitlements.
    // if VM has too much to do (recursive API calls), we need to address that in our API
    // think: how would everything work, if we have 250 persons? or 1000?
    // I think I have to adapt the API for that.

    Entitlement? entitlement = getPersonEntitlement(person, personEntitlements, entitlementCauses);

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
