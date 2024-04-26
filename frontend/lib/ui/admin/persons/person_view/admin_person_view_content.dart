import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/audit_item.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/setup/navigation/navigation_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/commons/audit_log_content.dart';
import 'package:frontend/ui/admin/commons/tab_container.dart';
import 'package:frontend/ui/admin/entitlements/view/entitlement_view_page.dart';
import 'package:frontend/ui/admin/persons/edit_person/edit_person_page.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:go_router/go_router.dart';

class PersonViewContent extends StatelessWidget {
  final Person person;
  final List<Entitlement>? entitlements;
  final List<AuditItem>? audit;

  const PersonViewContent({super.key, required this.person, this.entitlements, this.audit});

  final editPerson = false;

  @override
  Widget build(BuildContext context) {
    NavigationService navigationService = sl<NavigationService>();
    AppLocalizations lang = AppLocalizations.of(context)!;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.all(mediumPadding),
      child: Column(children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: largeSpace),
          child: SizedBox(
            child: Column(
              children: [
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
                    OflTab(label: lang.entitlements, content: campaignTabContent(context, entitlements)),
                    OflTab(label: lang.audit_log, content: auditLogContent(context, audit ?? [])),
                  ],
                ),
              ],
            ),
          ),
        ),
        largeVerticalSpacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OflButton(lang.back, () {
              context.pop();
            }),
            OflButton(lang.edit_person, () {
              navigationService.pushNamedWithCampaignId(context, EditPersonPage.routeName, pathParameters: {
                'personId': person.id,
              });
            }),
          ],
        ),
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
          personFieldText(context, formatDateShort(context, person.dateOfBirth)),
          isRequired: true,
        ),
        verticalPersonDetail(context, lang.email_address, personFieldText(context, person.email)),
      ],
    );
  }

  Widget campaignTabContent(BuildContext context, List<Entitlement>? entitlements) {
    NavigationService navigationService = sl<NavigationService>();
    AppLocalizations lang = AppLocalizations.of(context)!;
    final list = entitlements
        ?.map((item) => DataRow(
                onSelectChanged: (selected) {
                  navigationService.goNamedWithCampaignId(context, EntitlementViewPage.routeName, pathParameters: {
                    'personId': person.id,
                    'entitlementId': item.id,
                  });
                },
                cells: [
                  DataCell(Text(formatDateShort(context, item.createdAt) ?? 'kein Datum vorhanden')),
                  DataCell(Text(item.campaign?.name ?? 'kein Name vorhanden')),
                  DataCell(Text(item.entitlementCause?.name ?? 'kein Name vorhanden')),
                  DataCell(Text(formatDateShort(context, item.confirmedAt) ?? 'kein Datum vorhanden')),
                  DataCell(Text(formatDateShort(context, item.expiresAt) ?? 'kein Datum vorhanden')),
                ]))
        .toList();
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DataTable(
          showCheckboxColumn: false,
          columns: [
            DataColumn(label: Text(lang.created_at)),
            DataColumn(label: Text(lang.name)),
            DataColumn(label: Text(lang.entitlement_cause)),
            DataColumn(label: Text(lang.confirmed_at)),
            DataColumn(label: Text(lang.expires_at)),
          ],
          rows: list ?? [],
        ),
      ],
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
