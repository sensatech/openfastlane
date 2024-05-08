import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/person/address/address_model.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/setup/navigation/go_router.dart';
import 'package:frontend/setup/navigation/navigation_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:go_router/go_router.dart';

class ScannerPersonListContent extends StatelessWidget {
  const ScannerPersonListContent({
    super.key,
    this.campaignId,
    this.campaignName,
    required this.persons,
    this.checkOnly,
  });

  final String? campaignId;
  final String? campaignName;
  final List<Person> persons;
  final bool? checkOnly;

  @override
  Widget build(BuildContext context) {
    return personTable(context, persons);
  }

  Widget personTable(BuildContext context, List<Person> persons) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    NavigationService navigationService = sl<NavigationService>();
    return Row(
      children: [
        Expanded(
          child: DataTable(
            showCheckboxColumn: false,
            columnSpacing: 2,
            columns: [
              DataColumn(label: Text(lang.name)),
              DataColumn(label: Text(lang.address)),
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
    AppLocalizations lang = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(lang.no_entitlement_found),
      content: Text(lang.no_entitlement_text),
      actions: <Widget>[
        OflButton(
          lang.understood,
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
