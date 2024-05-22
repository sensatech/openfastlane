import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_info.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/person/address/address_model.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/setup/navigation/navigation_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/entitlements/create_edit/create_entitlement_page.dart';
import 'package:frontend/ui/admin/entitlements/view/entitlement_view_page.dart';
import 'package:frontend/ui/admin/persons/edit_person/edit_person_page.dart';
import 'package:frontend/ui/admin/persons/person_view/admin_person_view_page.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

class AdminPersonListTable extends StatefulWidget {
  final List<Person> persons;
  final String? campaignId;
  final Function onPop;

  const AdminPersonListTable({
    super.key,
    required this.persons,
    required this.campaignId,
    required this.onPop,
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

  @override
  void didUpdateWidget(covariant AdminPersonListTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    currentSortedData = widget.persons;
    rebuildTable();
  }

  void rebuildTable() {
    setState(() {
      currentSortedData.sort((first, second) {
        int result = 0;
        switch (sortColumnIndex) {
          case 1:
            result = first.firstName.compareTo(second.firstName);
            break;
          case 2:
            result = first.lastName.compareTo(second.lastName);
            break;
          case 3:
            final a = first.dateOfBirth ?? DateTime(0);
            final b = second.dateOfBirth ?? DateTime(0);
            result = a.compareTo(b);
            break;
          case 4:
            final a = first.address?.streetNameNumber ?? '';
            final b = second.address?.streetNameNumber ?? '';
            result = a.compareTo(b);
            break;
          case 5:
            final a = first.address?.postalCode ?? '';
            final b = second.address?.postalCode ?? '';
            result = a.compareTo(b);
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
    return Row(
      children: [
        Expanded(
          child: DataTable(
            showCheckboxColumn: false,
            sortColumnIndex: sortColumnIndex,
            sortAscending: sortAscending,
            columnSpacing: smallPadding,
            columns: personTableColumns(context),
            rows: [
              ...currentSortedData.map((person) => personTableRow(
                    context,
                    person,
                    loadAllPersonsWithEntitlements: widget.onPop,
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
      onSelectChanged: (value) {
        navigationService
            .goNamedWithCampaignId(context, AdminPersonViewPage.routeName, pathParameters: {'personId': person.id});
      },
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
        DataCell(Text(person.firstName)),
        DataCell(Text(person.lastName)),
        DataCell(Text(formatDateLong(context, person.dateOfBirth) ?? lang.invalid_date)),
        DataCell(Text(person.address?.fullAddressAsString ?? lang.no_address_available)),
        DataCell(Text(person.address?.postalCode ?? lang.no_address_available)),
        if (widget.campaignId != null)
          DataCell(getConsumptionCellContent(context, person,
              loadAllPersonsWithEntitlements: loadAllPersonsWithEntitlements)),
        if (widget.campaignId != null)
          DataCell(getExpirationCellContent(context, person,
              loadAllPersonsWithEntitlements: loadAllPersonsWithEntitlements)),
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
      if (widget.campaignId != null) DataColumn(label: headerText(lang.last_collection), onSort: onSortClicked),
      if (widget.campaignId != null) DataColumn(label: headerText(lang.status), onSort: onSortClicked)
    ];
  }

  Expanded headerText(String label) =>
      Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)));

  Widget getConsumptionCellContent(
    BuildContext context,
    Person person, {
    required Function loadAllPersonsWithEntitlements,
  }) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    ConsumptionInfo? lastConsumption;

    if (widget.campaignId != null && person.lastConsumptions != null && person.lastConsumptions!.isNotEmpty) {
      lastConsumption =
          person.lastConsumptions!.where((element) => element.campaignId == widget.campaignId).firstOrNull;
    }
    if (lastConsumption != null) {
      String formattedExpirationDate = formatDateTimeLong(context, lastConsumption.consumedAt) ?? lang.invalid_date;
      return TextButton(
          onPressed: () async {
            navigationService.goNamedWithCampaignId(context, EntitlementViewPage.routeName,
                pathParameters: {'personId': person.id, 'entitlementId': lastConsumption!.entitlementId});
          },
          child: Text(formattedExpirationDate,
              style: TextStyle(color: colorScheme.secondary, decoration: TextDecoration.underline)));
    } else {
      return const SizedBox();
    }
  }

  Widget getExpirationCellContent(
    BuildContext context,
    Person person, {
    required Function loadAllPersonsWithEntitlements,
  }) {
    AppLocalizations lang = AppLocalizations.of(context)!;
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
          child: Text('+ ${lang.create_entitlement}',
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
    if (widget.campaignId != null) {
      return person.entitlements?.where((element) => element.campaignId == widget.campaignId).firstOrNull;
    } else {
      return null;
    }
  }

  ExpirationUiInfo getExpirationUiInfo(Entitlement entitlement) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    DateTime? expirationDate = entitlement.expiresAt;
    String formattedExpirationDate = formatDateLong(context, expirationDate) ?? lang.invalid_date;
    if (expirationDate == null) {
      return ExpirationUiInfo(text: lang.entitlement_invalid, color: Colors.grey);
    } else {
      DateTime today = DateTime.now();
      if (expirationDate.isBefore(today)) {
        return ExpirationUiInfo(text: '${lang.expired_on} $formattedExpirationDate', color: Colors.red);
      } else if (expirationDate.difference(today).inDays < 30) {
        return ExpirationUiInfo(text: '${lang.valid_until} $formattedExpirationDate', color: Colors.orange);
      } else {
        return ExpirationUiInfo(text: '${lang.valid_until} $formattedExpirationDate', color: Colors.green);
      }
    }
  }
}

class ExpirationUiInfo {
  final String text;
  final Color? color;

  ExpirationUiInfo({required this.text, this.color});
}
