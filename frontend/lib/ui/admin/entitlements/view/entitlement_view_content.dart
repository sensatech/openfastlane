import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:frontend/ui/commons/values/size_values.dart';
import 'package:frontend/ui/commons/widgets/buttons.dart';
import 'package:go_router/go_router.dart';

class EntitlementViewContent extends StatelessWidget {
  const EntitlementViewContent({super.key, required this.entitlementInfo, required this.validateEntitlement});

  final EntitlementInfo entitlementInfo;
  final Function validateEntitlement;

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
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: largeSpace),
            child: SizedBox(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(lang.entitlement_cause,
                        style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  mediumVerticalSpacer(),
                  criteriaSelectionRow(context, lang.entitlement_cause,
                      field: entitlementCauseText(context, cause.name)),
                  largeVerticalSpacer(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(lang.entitlement_criterias,
                        style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  mediumVerticalSpacer(),
                  ...entitlement.values.map((value) {
                    String? name =
                        cause.criterias.firstWhereOrNull((criteria) => criteria.id == value.criteriaId)?.name;

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: smallPadding),
                      child: criteriaSelectionRow(context, name ?? lang.name_unknown,
                          field: entitlementValueText(context, value)),
                    );
                  }),
                  largeVerticalSpacer(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Status', style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  mediumVerticalSpacer(),
                  criteriaSelectionRow(context, 'Status',
                      field: entitlementCauseText(context, status.toLocale(context), color: status.toColor())),
                  mediumVerticalSpacer(),
                  criteriaSelectionRow(context, 'Gültig bis',
                      field: entitlementCauseText(
                          context, formatDateTimeShort(context, entitlement.expiresAt) ?? 'kein Datum vorhanden')),
                  mediumVerticalSpacer(),
                  const Divider(),
                  mediumVerticalSpacer(),
                  TabContainer(
                    tabs: [
                      OflTab(
                          label: lang.previous_consumptions,
                          content: PreviousConsumptionsTabContent(
                              consumptions: entitlementInfo.consumptions, campaignName: entitlementInfo.campaignName)),
                      OflTab(label: 'Audit Log', content: auditLogContent(context, entitlementInfo.entitlement.audit))
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
              Row(
                children: [
                  OflButton((entitlement.expiresAt != null) ? 'Anspruch verlängern' : 'Anspruch anlegen', () {
                    _showExtendDialog(context, entitlement.expiresAt == null, () {
                      validateEntitlement();
                    });
                  }),
                  smallHorizontalSpacer(),
                  OflButton(lang.edit_entitlement, () {
                    navigationService.pushNamedWithCampaignId(context, EditEntitlementPage.routeName,
                        pathParameters: {'personId': entitlement.personId, 'entitlementId': entitlement.id});
                  }),
                ],
              )
            ],
          ),
        ],
      ),
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

  Future<void> _showExtendDialog(BuildContext context, bool isFirstActivation, Function onTap) async {
    String text = (isFirstActivation) ? 'Aktivieren' : 'Verlängern';

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Anspruch ${text.toLowerCase()}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Wollen sie den Anspruch wirklich ${text.toLowerCase()}?'),
              ],
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OflButton(
                  'Abbrechen',
                  () {
                    context.pop();
                  },
                  color: Colors.transparent,
                  textColor: Colors.black,
                ),
                OflButton(
                  text,
                  () {
                    context.pop();
                    onTap();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
