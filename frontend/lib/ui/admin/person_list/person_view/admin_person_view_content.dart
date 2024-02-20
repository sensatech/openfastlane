import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/ui/admin/admin_values.dart';
import 'package:frontend/ui/admin/commons/tab_container.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:frontend/ui/commons/values/spacer.dart';

class PersonViewContent extends StatelessWidget {
  const PersonViewContent({super.key, required this.person});

  final Person person;
  final editPerson = false;

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    TextTheme textTheme = Theme.of(context).textTheme;
    Widget horizontalSpace = largeHorizontalSpacer();
    Widget verticalSpace = mediumVerticalSpacer();
    return SizedBox(
      width: smallContentWidth,
      child: Column(children: [
        Row(
          children: [
            Text(lang.view_person, style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        largeVerticalSpacer(),
        horizontalPersonField(textTheme, lang.salutation, personFieldText(context, person.gender?.toLocale(context))),
        verticalSpace,
        Row(
          children: [
            verticalPersonField(context, lang.firstname, personFieldText(context, person.firstName), isRequired: true),
            verticalPersonField(context, lang.lastname, personFieldText(context, person.lastName), isRequired: true),
            verticalPersonField(
                context, lang.birthdate, personFieldText(context, getFormattedDate(context, person.dateOfBirth)),
                isRequired: true),
            verticalPersonField(context, lang.email_address, personFieldText(context, person.email)),
          ],
        ),
        verticalSpace,
        Row(
          children: [
            verticalPersonField(
                context, lang.street_housenumber, personFieldText(context, person.address?.streetNameNumber),
                isRequired: true),
            horizontalSpace,
            verticalPersonField(context, lang.stairs_door, personFieldText(context, person.address?.addressSuffix),
                isRequired: true),
            horizontalSpace,
            verticalPersonField(context, lang.zip, personFieldText(context, person.address?.postalCode),
                isRequired: true),
            horizontalSpace,
            verticalPersonField(context, lang.mobile_number, personFieldText(context, person.mobileNumber)),
          ],
        ),
        verticalSpace,
        Align(
            alignment: Alignment.centerLeft,
            child: verticalPersonField(context, lang.comment,
                personFieldText(context, (person.comment == '') ? lang.no_comment : person.comment),
                isRequired: false)),
        largeVerticalSpacer(),
        const Divider(),
        largeVerticalSpacer(),
        Expanded(
          child: SingleChildScrollView(
            child: TabContainer(
              tabs: [
                //TODO: Fetch Entitlements from backend
                OflTab(label: 'MOCK: Lebensmittelpakete', content: campaignTabContent()),
                OflTab(label: lang.audit_log, content: auditLogContent()),
              ],
            ),
          ),
        )
      ]),
    );
  }

  Center auditLogContent() {
    return const Center(child: Text('Tab2 Content'));
  }

  Center campaignTabContent() {
    return const Center(child: Text('Tab1 Content'));
  }

  Text personFieldText(BuildContext context, String? text) {
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations lang = AppLocalizations.of(context)!;
    text = (text != null) ? text : lang.unknown;
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
