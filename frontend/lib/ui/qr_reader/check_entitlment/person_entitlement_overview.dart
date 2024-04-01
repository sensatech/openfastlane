import 'package:flutter/material.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';

class PersonEntitlementOverview extends StatelessWidget {
  final Entitlement entitlement;
  final VoidCallback onPersonClicked;

  const PersonEntitlementOverview({super.key, required this.entitlement, required this.onPersonClicked});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        child: Center(
          child: Table(
            children: <TableRow>[
              buildTableRow('Name', 'Max Mustermann', onClick: onPersonClicked),
              buildTableRow('Geburtsdatum', '12.12.2000'),
              buildTableRow('Kampagne', 'Lebensmittelausgabe'),
              buildTableRow('Ansuchgrund', 'Ukraine'),
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
