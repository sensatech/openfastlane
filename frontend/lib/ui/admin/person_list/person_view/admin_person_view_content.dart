import 'package:flutter/material.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/ui/admin/admin_values.dart';
import 'package:frontend/ui/admin/commons/tab_container.dart';
import 'package:frontend/ui/commons/values/date_extension.dart';
import 'package:frontend/ui/commons/values/spacer.dart';

class PersonViewContent extends StatelessWidget {
  const PersonViewContent({super.key, required this.person});

  final Person person;
  final editPerson = false;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    Widget horizontalSpace = largeHorizontalSpacer();
    Widget verticalSpace = mediumVerticalSpacer();
    return SizedBox(
      width: smallContentWidth,
      child: Column(children: [
        Row(
          children: [
            Text('Person Ansehen', style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        largeVerticalSpacer(),
        horizontalPersonField(textTheme, 'Anrede', personFieldText(textTheme, person.gender?.toLocale(context))),
        verticalSpace,
        Row(
          children: [
            verticalPersonField(context, 'Vorname', personFieldText(textTheme, person.firstName), isRequired: true),
            verticalPersonField(context, 'Nachname', personFieldText(textTheme, person.lastName), isRequired: true),
            verticalPersonField(context, 'Geburtsdatum', personFieldText(textTheme, person.dateOfBirth.formatDE),
                isRequired: true),
            verticalPersonField(context, 'E-Mail-Adresse', personFieldText(textTheme, person.email)),
          ],
        ),
        verticalSpace,
        Row(
          children: [
            verticalPersonField(
                context, 'Straße/Hausenummer', personFieldText(textTheme, person.address?.streetNameNumber),
                isRequired: true),
            horizontalSpace,
            verticalPersonField(context, 'Stiege/Tür', personFieldText(textTheme, person.address?.addressSuffix),
                isRequired: true),
            horizontalSpace,
            verticalPersonField(context, 'Postleitzahl', personFieldText(textTheme, person.address?.postalCode),
                isRequired: true),
            horizontalSpace,
            verticalPersonField(context, 'Mobilnummer', personFieldText(textTheme, person.mobileNumber)),
          ],
        ),
        largeVerticalSpacer(),
        const Divider(),
        largeVerticalSpacer(),
        Expanded(
          child: SingleChildScrollView(
            child: TabContainer(
              tabs: [
                OflTab(label: 'Tab1', content: const Center(child: Text('Tab1 Content'))),
                OflTab(label: 'Tab2', content: const Center(child: Text('Tab2 Content'))),
              ],
            ),
          ),
        )
      ]),
    );
  }

  Text personFieldText(TextTheme textTheme, String? text) {
    text = (text != null) ? text : 'unbekannt';
    return Text(text, style: textTheme.bodyLarge);
  }

  Widget verticalPersonField(BuildContext context, String label, Widget fieldContent, {bool isRequired = false}) {
    String requiredStar = (isRequired) ? '*' : '';
    TextTheme textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:$requiredStar', style: textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
          smallVerticalSpacer(),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: fieldContent,
          )
        ],
      ),
    );
  }

  Row horizontalPersonField(TextTheme textTheme, String label, Widget fieldContent, {bool isRequired = false}) {
    String requiredStar = (isRequired) ? '*' : '';
    return Row(
      children: [
        Text('$label:$requiredStar', style: textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
        smallHorizontalSpacer(),
        fieldContent
      ],
    );
  }
}
