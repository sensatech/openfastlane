import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/person/address/address_model.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/setup/navigation/navigation_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/entitlements/create_edit/create_entitlement_page.dart';
import 'package:frontend/ui/admin/entitlements/view/entitlement_view_page.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_vm.dart';
import 'package:frontend/ui/admin/persons/edit_person/edit_person_page.dart';
import 'package:frontend/ui/admin/persons/person_view/admin_person_view_page.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

class AdminPersonListTable extends StatefulWidget {
  final List<Person> persons;
  final String campaignId;

  const AdminPersonListTable({
    super.key,
    required this.persons,
    required this.campaignId,
  });

  @override
  State<AdminPersonListTable> createState() => _AdminPersonListPageState();
}

class _AdminPersonListPageState extends State<AdminPersonListTable> {
  int? sortColumnIndex;
  bool sortAscending = true;

  List<Person> currentSortedData = [];

  NavigationService navigationService = sl<NavigationService>();

  @override
  void initState() {
    super.initState();
    sortColumnIndex = null;

    currentSortedData = widget.persons;
  }

  void rebuildTable() {
    setState(() {
      currentSortedData.sort((a, b) {
        Person first = a;
        Person second = b;

        int result = 0;
        switch (sortColumnIndex) {
          case 1:
            result = first.firstName.compareTo(second.firstName);
            break;
          case 2:
            result = first.lastName.compareTo(second.lastName);
            break;
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
    return Row(
      children: [
        Expanded(
          child: DataTable(
            sortColumnIndex: sortColumnIndex,
            sortAscending: sortAscending,
            columnSpacing: smallPadding,
            columns: personTableColumns(context),
            rows: [
              ...currentSortedData.map((person) => personTableRow(
                    context,
                    person,
                    loadAllPersonsWithEntitlements: () => viewModel.loadAllPersonsWithEntitlements(),
                  ))
            ],
          ),
        ),
      ],
    );
  }

  DataRow personTableRow(
    BuildContext context,
    Person person, {
    required Function loadAllPersonsWithEntitlements,
  }) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    NavigationService navigationService = sl<NavigationService>();

    return DataRow(
      cells: [
        DataCell(Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
                onPressed: () {
                  navigationService.goNamedWithCampaignId(context, AdminPersonViewPage.routeName,
                      pathParameters: {'personId': person.id});
                },
                icon: const Icon(Icons.remove_red_eye)),
            IconButton(
                onPressed: () async {
                  await navigationService.pushNamedWithCampaignId(context, EditPersonPage.routeName,
                      pathParameters: {'personId': person.id});
                  loadAllPersonsWithEntitlements.call();
                },
                icon: const Icon(Icons.edit))
          ],
        )),
        DataCell(Text(person.firstName), onTap: () {
          navigationService
              .goNamedWithCampaignId(context, AdminPersonViewPage.routeName, pathParameters: {'personId': person.id});
        }),
        DataCell(Text(person.lastName)),
        DataCell(Text(getFormattedDateAsString(context, person.dateOfBirth) ?? lang.invalid_date)),
        DataCell(Text(person.address?.fullAddressAsString ?? lang.no_address_available)),
        DataCell(Text(person.address?.postalCode ?? lang.no_address_available)),
        DataCell(getConsumptionCellContent(context, person,
            loadAllPersonsWithEntitlements: () => loadAllPersonsWithEntitlements.call())),
        DataCell(getExpirationCellContent(context, person,
            loadAllPersonsWithEntitlements: () => loadAllPersonsWithEntitlements.call())),
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

  Widget getConsumptionCellContent(BuildContext context, Person person,
      {required Function loadAllPersonsWithEntitlements}) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    if (person.lastConsumptions != null && person.lastConsumptions!.isNotEmpty) {
      return TextButton(
          onPressed: () async {
            await navigationService.pushNamedWithCampaignId(context, CreateEntitlementPage.routeName,
                pathParameters: {'personId': person.id});
            loadAllPersonsWithEntitlements.call();
          },
          child: Text(lang.create_entitlement,
              style: TextStyle(color: colorScheme.secondary, decoration: TextDecoration.underline)));
    } else {
      return const SizedBox();
    }
  }

  Widget getExpirationCellContent(BuildContext context, Person person,
      {required Function loadAllPersonsWithEntitlements}) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    Entitlement? entitlement = firstCampaignEntitlement(person);

    if (entitlement == null) {
      Color color = colorScheme.secondary;
      return TextButton(
          onPressed: () async {
            await navigationService.pushNamedWithCampaignId(context, CreateEntitlementPage.routeName,
                pathParameters: {'personId': person.id});
            loadAllPersonsWithEntitlements.call();
          },
          child: Text('+ Anspruchsberechtigung anlegen',
              style: TextStyle(color: color, decoration: TextDecoration.underline, decorationColor: color)));
    } else {
      ExpirationUiInfo expirationUiInfo = getExpirationUiInfo(entitlement);
      Color color = expirationUiInfo.color ?? colorScheme.secondary;

      return TextButton(
          onPressed: () {
            navigationService.goNamedWithCampaignId(context, EntitlementViewPage.routeName,
                pathParameters: {'personId': person.id, 'entitlementId': entitlement.id});
          },
          child: Text(expirationUiInfo.text,
              style: TextStyle(
                  color: expirationUiInfo.color, decoration: TextDecoration.underline, decorationColor: color)));
    }
  }

  Entitlement? firstCampaignEntitlement(Person person) {
    return person.entitlements?.where((element) => element.campaignId == widget.campaignId).firstOrNull;
  }

  ExpirationUiInfo getExpirationUiInfo(Entitlement entitlement) {
    DateTime? expirationDate = entitlement.expiresAt;
    if (expirationDate == null) {
      return ExpirationUiInfo(text: 'Ablaufdatum nicht vorhanden', color: Colors.grey);
    } else {
      DateTime today = DateTime.now();
      if (expirationDate.isBefore(today)) {
        return ExpirationUiInfo(text: 'Anspruch abgelaufen', color: Colors.red);
      } else if (expirationDate.difference(today).inDays < 30) {
        return ExpirationUiInfo(
            text: getFormattedDateAsString(context, expirationDate) ?? 'Ablaufdatum nicht vorhanden',
            color: Colors.orange);
      } else {
        return ExpirationUiInfo(
            text: getFormattedDateAsString(context, expirationDate) ?? 'Ablaufdatum nicht vorhanden',
            color: Colors.green);
      }
    }
  }
}

class ExpirationUiInfo {
  final String text;
  final Color? color;

  ExpirationUiInfo({required this.text, this.color});
}
