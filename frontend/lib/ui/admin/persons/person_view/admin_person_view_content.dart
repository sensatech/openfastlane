import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/audit_item.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/ui/admin/admin_values.dart';
import 'package:frontend/ui/admin/commons/tab_container.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:frontend/ui/commons/values/spacer.dart';

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
    return SizedBox(
      width: smallContentWidth,
      child: Column(children: [
        Text(lang.view_person, style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
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
        Expanded(
          child: SingleChildScrollView(
            child: TabContainer(
              tabs: [
                OflTab(label: 'Anspruchsberechtigungen', content: campaignTabContent(entitlements)),
                OflTab(label: lang.audit_log, content: auditLogContent(history ?? [])),
              ],
            ),
          ),
        )
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

  Center campaignTabContent(List<Entitlement>? entitlements) {
    // TODO: implement UI properly, just testing API right now
    var list = entitlements
            ?.map(
              (e) => buildEntitlement(e),
            )
            .toList() ??
        [const Text('No entitlements available')];
    return Center(child: Row(children: list));
  }

  // TODO: implement UI properly, just testing API right now
  Widget buildEntitlement(Entitlement item) {
    var list = item.values.map((value) => Text("Value: ${value.value}")).toList();
    return Padding(
      padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Text("Entitlement: "),
              const SizedBox(width: 8),
              const Text("entitlementCauseId: "),
              ...list,
            ],
      ),
    );
  }

  Center auditLogContent(List<AuditItem> history) {
    // return const Center(child: Text('Tab2 Content'));
    final list = history
        .map((item) => Row(
              children: [
                Text(item.dateTime.toString()),
                Text(item.user),
                Text(item.action),
                Text(item.message),
                const SizedBox(width: 8),
              ],
            ))
        .toList();
    return Center(child: Row(children: list));
  }

  Text personFieldText(BuildContext context, String? text) {
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations lang = AppLocalizations.of(context)!;
    text = (text != null) ? text : lang.unknown;

    return Text(text, style: textTheme.bodyLarge);
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
