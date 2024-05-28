import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_possibility.dart';
import 'package:frontend/domain/entitlements/consumption/consumption_possibility_type.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/entitlements/entitlement_status.dart';
import 'package:frontend/domain/entitlements/entitlement_value.dart';
import 'package:frontend/setup/navigation/navigation_service.dart';
import 'package:frontend/setup/setup_dependencies.dart';
import 'package:frontend/ui/admin/commons/audit_log_content.dart';
import 'package:frontend/ui/admin/commons/tab_container.dart';
import 'package:frontend/ui/admin/entitlements/create_edit/commons.dart';
import 'package:frontend/ui/admin/entitlements/create_edit/edit_entitlement_page.dart';
import 'package:frontend/ui/admin/entitlements/view/entitlement_view_vm.dart';
import 'package:frontend/ui/admin/entitlements/view/previous_consumptions/previous_consumptions_tab_content.dart';
import 'package:frontend/ui/commons/show_dialog.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:frontend/ui/commons/widgets/ofl_link.dart';
import 'package:go_router/go_router.dart';

class EntitlementViewContent extends StatelessWidget {
  const EntitlementViewContent({
    super.key,
    required this.entitlementInfo,
    required this.validateEntitlement,
    required this.getQrPdf,
    required this.performConsumption,
  });

  final EntitlementInfo entitlementInfo;
  final Function validateEntitlement;
  final Function getQrPdf;
  final Function performConsumption;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations lang = AppLocalizations.of(context)!;
    NavigationService navigationService = sl<NavigationService>();

    Entitlement entitlement = entitlementInfo.entitlement;
    EntitlementCause cause = entitlementInfo.cause;
    EntitlementStatus status = entitlementInfo.entitlement.status;

    return Padding(
        padding: EdgeInsets.all(mediumPadding),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: largeSpace),
          child: SizedBox(
            child: Column(children: [
              contextMenu(lang, context, entitlement, navigationService),
              largeVerticalSpacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // entitlement_cause
                      sectionHeadline(lang.entitlement_cause, textTheme),
                      mediumVerticalSpacer(),
                      criteriaSelectionRow(context, lang.entitlement_cause, child: entitlementCauseText(context, cause.name)),
                      largeVerticalSpacer(),
                      // entitlement_criterias
                      sectionHeadline(lang.entitlement_criterias, textTheme),
                      mediumVerticalSpacer(),
                      ...entitlement.values.map((value) {
                        String? name = cause.criterias.firstWhereOrNull((criteria) => criteria.id == value.criteriaId)?.name;

                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: smallPadding),
                          child: criteriaSelectionRow(context, name ?? lang.name_unknown, child: entitlementValueText(context, value)),
                        );
                      }),
                      largeVerticalSpacer(),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // status
                      sectionHeadline(lang.status, textTheme),
                      mediumVerticalSpacer(),
                      criteriaSelectionRow(context, lang.status,
                          child: entitlementCauseText(context, status.toLocale(context), color: status.toColor())),
                      mediumVerticalSpacer(),
                      criteriaSelectionRow(context, lang.valid_until,
                          child:
                              entitlementCauseText(context, formatDateTimeShort(context, entitlement.expiresAt) ?? lang.no_date_available)),
                      largeVerticalSpacer(),
                      // consumption_possibility
                      if (entitlementInfo.consumptionPossibility != null)
                        showConsumptionPossibility(context, entitlementInfo.consumptionPossibility!, performConsumption),
                    ],
                  ),
                ],
              ),
              const Divider(),
              mediumVerticalSpacer(),
              TabContainer(
                tabs: [
                  OflTab(
                      label: lang.previous_consumptions,
                      content: PreviousConsumptionsTabContent(
                          consumptions: entitlementInfo.consumptions ?? [], campaignName: entitlementInfo.campaignName)),
                  OflTab(label: lang.audit_log, content: auditLogContent(context, entitlementInfo.auditLogs))
                ],
              ),
            ]),
          ),
        ));
  }

  Align sectionHeadline(String label, TextTheme textTheme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(label, style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Row contextMenu(AppLocalizations lang, BuildContext context, Entitlement entitlement, NavigationService navigationService) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OflButton(lang.back, () {
          context.pop();
        }),
        Row(
          children: [
            if (entitlement.expiresAt != null)
              OflButton(lang.extend_entitlement, () {
                showConfirmDialog(context,
                    title: '${lang.entitlement} ${lang.extend.toLowerCase()}',
                    body: '${lang.extend} ?',
                    submitText: lang.extend,
                    onTap: () {
                  validateEntitlement();
                });
              })
            else
              OflButton(lang.activate_entitlement, () {
                showConfirmDialog(context,
                    title: '${lang.entitlement} ${lang.activate.toLowerCase()}',
                    body: '${lang.activate} ?',
                    submitText: lang.activate,
                    onTap: () {
                      validateEntitlement();
                    });
              }),
            smallHorizontalSpacer(),
            OflButton(lang.edit_entitlement, () {
              navigationService.pushNamedWithCampaignId(context, EditEntitlementPage.routeName,
                  pathParameters: {'personId': entitlement.personId, 'entitlementId': entitlement.id});
            }),
            smallHorizontalSpacer(),
            OflLink(lang.view_entitlement_pdf, () {
              getQrPdf();
            }),
          ],
        )
      ],
    );
  }

  Widget entitlementCauseText(BuildContext context, String text, {Color? color}) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Text(text, style: textTheme.bodyMedium!.copyWith(color: color), textAlign: TextAlign.right);
  }

  Widget entitlementValueText(BuildContext context, EntitlementValue value) {
    AppLocalizations lang = AppLocalizations.of(context)!;
    TextTheme textTheme = Theme.of(context).textTheme;
    return Text(
      getDisplayValue(context, value) ?? lang.value_unknown,
      style: textTheme.bodyMedium,
      textAlign: TextAlign.right,
    );
  }

  showConsumptionPossibility(BuildContext context, ConsumptionPossibility consumptionPossibility, Function performConsumption) {
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations lang = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionHeadline(lang.current_consumption_possibility, textTheme),
        mediumVerticalSpacer(),
        criteriaSelectionRow(context, lang.current_consumption_possibility,
            child: entitlementCauseText(context, entitlementInfo.consumptionPossibility!.status.toLocale(context))),
        mediumVerticalSpacer(),
        if (consumptionPossibility.lastConsumptionAt != null)
          criteriaSelectionRow(context, lang.last_consumption_on,
              child: entitlementCauseText(context,
                  formatDateTimeShort(context, entitlementInfo.consumptionPossibility!.lastConsumptionAt) ?? lang.no_date_available)),
        mediumVerticalSpacer(),
        if (consumptionPossibility.status == ConsumptionPossibilityType.consumptionPossible)
          Align(alignment: Alignment.centerRight, child: OflButton(lang.enter_consumption,  () {
            showConfirmDialog(context,
                title: lang.enter_consumption,
                body: lang.enter_consumption_question,
                submitText: 'Ja',
                onTap: () {
                  performConsumption();
                });
          }))
      ],
    );
  }
}
