import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/person/address/address_model.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/setup/navigation/go_router.dart';
import 'package:frontend/setup/navigation/navigation_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:go_router/go_router.dart';

class ScannerPersonListContent extends StatelessWidget {
  const ScannerPersonListContent(
      {super.key,
      this.campaignId,
      this.campaignName,
      required this.persons,
      this.checkOnly,
      required this.updateSearchInput});

  final String? campaignId;
  final String? campaignName;
  final List<Person> persons;
  final bool? checkOnly;
  final Function(String) updateSearchInput;

  @override
  Widget build(BuildContext context) {
    return personTable(context, persons);
  }

  Widget personTable(BuildContext context, List<Person> persons) {
    NavigationService navigationService = sl<NavigationService>();
    return Row(
      children: [
        Expanded(
          child: DataTable(
            showCheckboxColumn: false,
            columnSpacing: 2,
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Adresse')),
            ],
            rows: persons.map((person) {
              return DataRow(
                  onSelectChanged: (value) {
                    // find entitlement of current campaign
                    Entitlement? entitlement =
                        person.entitlements?.firstWhereOrNull((element) => element.campaignId == campaignId);

                    // navigate straight to entitlement
                    if (entitlement != null) {
                      navigationService.pushNamedWithCampaignId(context, ScannerRoutes.scannerEntitlement.name,
                          pathParameters: {'entitlementId': person.entitlements!.first.id},
                          queryParameters: {'checkOnly': checkOnly.toString()});
                    } else {
                      showDialog(context: context, builder: (context) => buildNoEntitlementDialog(context));
                    }
                  },
                  cells: [
                    DataCell(Text(person.name)),
                    DataCell(Text(person.address?.fullAddressAsString ?? '')),
                  ]);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget buildNoEntitlementDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Keine Anspruchsberechtigung'),
      content: const Text(
          'Für diese Person wurde noch keine Anspruchsberechtigung angelegt. Bitte wenden Sie sich an den Admin.'),
      actions: <Widget>[
        OflButton(
          'Verstanden',
          () {
            context.pop();
          },
          color: Colors.transparent,
          textColor: Colors.black,
        ),
      ],
    );
  }
}
