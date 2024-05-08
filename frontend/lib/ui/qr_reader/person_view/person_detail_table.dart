import 'package:flutter/material.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

class PersonDetailTable extends StatelessWidget {
  final Person person;

  const PersonDetailTable({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    String? dateOfBirth = formatDateLong(context, person.dateOfBirth);
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        child: Center(
          child: Table(
            children: <TableRow>[
              buildTableRow(context, 'Geburtsdatum: ', dateOfBirth ?? ''),
              buildTableRow(context, 'Straße/Nr: ', person.address?.streetNameNumber ?? ''),
              buildTableRow(context, 'Stiege/Tür: ', person.address?.addressSuffix ?? ''),
              buildTableRow(context, 'PLZ: ', person.address?.postalCode ?? ''),
              buildTableRow(context, 'Mobilnummer: ', person.mobileNumber ?? ''),
              buildTableRow(context, 'E-Mail-Adresse: ', person.email ?? ''),
            ],
          ),
        ));
  }

  TableRow buildTableRow(BuildContext context, String label, String value) {
    EdgeInsets padding = EdgeInsets.symmetric(vertical: smallPadding / 2, horizontal: smallPadding);
    TextTheme textTheme = Theme.of(context).textTheme;
    return TableRow(
      children: [
        Padding(
            padding: padding,
            child: Text(
              label,
              textAlign: TextAlign.end,
              style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
            )),
        Padding(padding: padding, child: tableValue(context, value)),
      ],
    );
  }

  Widget tableValue(BuildContext context, String value) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Text(value, style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.normal));
  }
}
