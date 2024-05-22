import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/audit_item.dart';
import 'package:frontend/domain/campaign/campaign_model.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/person/person_model.dart';
import 'package:frontend/setup/navigation/navigation_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/commons/audit_log_content.dart';
import 'package:frontend/ui/admin/commons/tab_container.dart';
import 'package:frontend/ui/admin/entitlements/create_edit/create_entitlement_page.dart';
import 'package:frontend/ui/admin/entitlements/view/entitlement_view_page.dart';
import 'package:frontend/ui/admin/persons/edit_person/edit_person_page.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:go_router/go_router.dart';

class PersonViewContent extends StatelessWidget {
  final Person person;
  final Campaign? campaign;
  final List<Entitlement>? entitlements;
  final List<AuditItem>? audit;

  const PersonViewContent({super.key, required this.person, this.campaign, this.entitlements, this.audit});

  final editPerson = false;

  @override
  Widget build(BuildContext context) {
    NavigationService navigationService = sl<NavigationService>();
    AppLocalizations lang = AppLocalizations.of(context)!;
    TextTheme textTheme = Theme.of(context).textTheme;

    Entitlement? entitlementForCampaign;
    if (campaign != null && entitlements != null) {
      entitlementForCampaign = entitlements!.firstWhereOrNull((element) => element.campaign?.id == campaign!.id);
    } else {
      entitlementForCampaign = null;
    }
    return Padding(
      padding: EdgeInsets.all(mediumPadding),
      child: Column(children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: largeSpace),
          child: SizedBox(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OflButton(lang.back, () {
                      context.pop();
                    }),
                    const Spacer(),
                    if (campaign != null)
                      if (entitlementForCampaign == null)
                        OflButton(campaign!.name + lang.person_view_campaign_create, () {
                          navigationService.pushNamedWithCampaignId(context, CreateEntitlementPage.routeName,
                              pathParameters: {'personId': person.id});
                        })
                      else
                        OflButton(campaign!.name + lang.person_view_campaign_edit, () {
                          navigationService.pushNamedWithCampaignId(context, EntitlementViewPage.routeName,
                              pathParameters: {'personId': person.id, 'entitlementId': entitlementForCampaign!.id});
                        }),
                    smallHorizontalSpacer(),
                    OflButton(lang.edit_person, () {
                      navigationService.pushNamedWithCampaignId(context, EditPersonPage.routeName, pathParameters: {
                        'personId': person.id,
                      });
                    }),
                  ],
                ),
                mediumVerticalSpacer(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(lang.view_person, style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
                ),
                mediumVerticalSpacer(),
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
                      lang.streetNameNumber,
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
          lang.dateOfBirth,
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
                  DataCell(Text(formatDateTimeShort(context, item.createdAt) ?? lang.no_date_available)),
                  DataCell(Text(item.campaign?.name ?? lang.no_name_available)),
                  DataCell(Text(item.entitlementCause?.name ?? lang.no_name_available)),
                  DataCell(Text(formatDateTimeShort(context, item.confirmedAt) ?? lang.no_date_available)),
                  DataCell(Text(formatDateTimeShort(context, item.expiresAt) ?? lang.no_date_available)),
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
            DataColumn(label: Text(lang.valid_until)),
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
