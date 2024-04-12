import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/audit_item.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/ui/admin/commons/tab_container.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:go_router/go_router.dart';

class PersonViewContent extends StatelessWidget {
  final Person person;
  final List<Entitlement>? entitlements;
  final List<AuditItem>? history;

  const PersonViewContent({super.key, required this.person, this.entitlements, this.history});

  final editPerson = false;

  @override
  Widget build(BuildContext context) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(lang.view_person, style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
        ),
        largeVerticalSpacer(),
        horizontalPersonField(
          textTheme,
          lang.salutation,
          personFieldText(context, person.gender?.toLocale(context)),
        ),
        mediumVerticalSpacer(),
        namesEmailDateOfBirth(context, lang),
        mediumVerticalSpacer(),
        Row(
          children: [
            verticalPersonDetail(
              context,
              lang.street_housenumber,
              personFieldText(context, person.address?.streetNameNumber),
              isRequired: true,
            ),
            verticalPersonDetail(
              context,
              lang.stairs_door,
              personFieldText(context, person.address?.addressSuffix),
              isRequired: true,
            ),
            verticalPersonDetail(
              context,
              lang.zip,
              personFieldText(context, person.address?.postalCode),
              isRequired: true,
            ),
            verticalPersonDetail(
              context,
              lang.mobile_number,
              personFieldText(context, person.mobileNumber),
            ),
          ],
        ),
        mediumVerticalSpacer(),
        Row(children: [
          verticalPersonDetail(
            context,
            lang.comment,
            personFieldText(context, (person.comment == '') ? lang.no_comment : person.comment),
            isRequired: false,
          )
        ]),
        largeVerticalSpacer(),
        const Divider(),
        largeVerticalSpacer(),
        TabContainer(
          tabs: [
            OflTab(label: 'Anspruchsberechtigungen', content: campaignTabContent(entitlements)),
            OflTab(label: lang.audit_log, content: auditLogContent(history ?? [])),
          ],
        ),
        mediumVerticalSpacer(),
        Align(
          alignment: Alignment.centerLeft,
          child: OflButton(lang.back, () {
            context.pop();
          }),
        ),
        largeVerticalSpacer(),
      ]),
    );
  }

  Row namesEmailDateOfBirth(BuildContext context, AppLocalizations lang) {
    return Row(
      children: [
        verticalPersonDetail(context, lang.firstname, personFieldText(context, person.firstName), isRequired: true),
        verticalPersonDetail(context, lang.lastname, personFieldText(context, person.lastName), isRequired: true),
        verticalPersonDetail(
          context,
          lang.birthdate,
          personFieldText(context, getFormattedDateAsString(context, person.dateOfBirth)),
          isRequired: true,
        ),
        verticalPersonDetail(context, lang.email_address, personFieldText(context, person.email)),
      ],
    );
  }

  Widget campaignTabContent(List<Entitlement>? entitlements) {
    final list = entitlements
        ?.map((item) => DataRow(cells: [
              DataCell(Text(item.createdAt.toString())),
              DataCell(Text(item.id.toString())),
              DataCell(Text(item.confirmedAt.toString())),
              DataCell(Text(item.expiresAt.toString())),
              DataCell(Text(item.values.map((value) => value.value).join(', '))),
            ]))
        .toList();
    return SingleChildScrollView(
        child: DataTable(
      columns: const [
        DataColumn(label: Text('Erstellt am')),
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Bestätigt seit')),
        DataColumn(label: Text('Läuft ab:')),
        DataColumn(label: Text('Werte:')),
      ],
      rows: list ?? [],
    ));
  }

  Widget auditLogContent(List<AuditItem> history) {
    // return const Center(child: Text('Tab2 Content'));
    final list = history
        .map((item) => DataRow(cells: [
              DataCell(Text(item.dateTime.toString())),
              DataCell(Text(item.user)),
              DataCell(Text(item.action)),
              DataCell(Text(item.message)),
            ]))
        .toList();
    return SingleChildScrollView(
        child: DataTable(
      columns: const [
        DataColumn(label: Text('Datum')),
        DataColumn(label: Text('User')),
        DataColumn(label: Text('Aktion')),
        DataColumn(label: Text('Info')),
      ],
      rows: list,
    ));
  }

  Widget personFieldText(BuildContext context, String? text) {
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations lang = AppLocalizations.of(context)!;
    text = (text != null) ? text : lang.unknown;

    return SelectableText(text, style: textTheme.bodyLarge);
  }

  Widget verticalPersonDetail(BuildContext context, String label, Widget fieldContent, {bool isRequired = false}) {
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
    ));
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
