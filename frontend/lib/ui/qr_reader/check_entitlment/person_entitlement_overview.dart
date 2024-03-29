import 'package:flutter/cupertino.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';

class PersonEntitlementOverview extends StatelessWidget {
  final Entitlement entitlement;

  const PersonEntitlementOverview({super.key, required this.entitlement});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        child: Center(
          child: Table(
            children: <TableRow>[
              TableRow(
                children: <Widget>[
                  tableLabel('Name'),
                  Text('Max Mustermann'),
                ],
              ),
              TableRow(
                children: <Widget>[
                  tableLabel('Geburtsdatum'),
                  tableValue('12.12.2000'),
                ],
              ),
              TableRow(
                children: <Widget>[
                  tableLabel('Kampagne'),
                  tableValue('Lebensmittelausgabe'),
                ],
              ),
              TableRow(
                children: <Widget>[
                  tableLabel('Ansuchgrund'),
                  tableValue('Ukraine'),
                ],
              ),
            ],
          ),
        ));
  }

  Widget tableLabel(String s) {
    return Text(s, style: const TextStyle(fontWeight: FontWeight.bold));
  }

  Widget tableValue(String s) {
    return Text(s, style: const TextStyle(fontWeight: FontWeight.normal));
  }
}
