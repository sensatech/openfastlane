import 'package:flutter/material.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/person/person_model.dart';

class PersonEntitlementOverview extends StatelessWidget {
  final Person? person;

  final EntitlementCause? entitlementCause;
  final VoidCallback onPersonClicked;

  const PersonEntitlementOverview({
    super.key,
    this.person,
    required this.entitlementCause,
    required this.onPersonClicked,
  });

  @override
  Widget build(BuildContext context) {
    var string = (person?.dateOfBirth ?? '').toString();
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        child: Center(
          child: Table(
            children: <TableRow>[
              // FIXME i18n
              buildTableRow('Name', person?.name ?? '', onClick: onPersonClicked),
              buildTableRow('Geburtsdatum', string),
              if (entitlementCause?.campaign?.name != null) buildTableRow('Kampagne', entitlementCause!.campaign!.name),
              if (entitlementCause?.name != null)
                buildTableRow('Ansuchgrund', entitlementCause!.name ?? 'name unbekannt'),
            ],
          ),
        ));
  }

  TableRow buildTableRow(
    String label,
    String value, {
    VoidCallback? onClick,
  }) {
    return TableRow(
      children: <Widget>[
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        if (onClick != null)
          InkWell(
            onTap: onClick,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          )
        else
          tableValue(value),
      ],
    );
  }

  Widget tableValue(String value) {
    return Text(value, style: const TextStyle(fontWeight: FontWeight.normal));
  }
}
