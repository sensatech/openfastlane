import 'package:flutter/material.dart';
import 'package:frontend/domain/person/person_model.dart';

class PersonDetailTable extends StatelessWidget {
  final Person person;

  const PersonDetailTable({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        child: Center(
          child: Table(
            children: <TableRow>[
              buildTableRow('Geburtsdatum: ', person.dateOfBirth.toString()),
              buildTableRow('Straße/Nr: ', person.address?.streetNameNumber ?? ''),
              buildTableRow('Stiege/Tür: ', person.address?.addressSuffix ?? ''),
              buildTableRow('PLZ: ', person.address?.postalCode ?? ''),
              buildTableRow('Mobilnummer: ', person.mobileNumber ?? ''),
              buildTableRow('E-Mail-Adresse: ', person.email ?? ''),
            ],
          ),
        ));
  }

  TableRow buildTableRow(String label, String value) {
    const edgeInsets = EdgeInsets.symmetric(vertical: 2, horizontal: 4);
    return TableRow(
      children: <Widget>[
        Padding(
            padding: edgeInsets,
            child: Text(
              label,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            )),
        Padding(padding: edgeInsets, child: tableValue(value)),
      ],
    );
  }

  Widget tableValue(String value) {
    return Text(value, style: const TextStyle(fontWeight: FontWeight.normal));
  }
}
