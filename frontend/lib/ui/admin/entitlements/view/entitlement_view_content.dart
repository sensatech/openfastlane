import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/audit_item.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/ui/admin/commons/admin_values.dart';
import 'package:frontend/ui/admin/commons/audit_log_content.dart';
import 'package:frontend/ui/admin/commons/tab_container.dart';
import 'package:frontend/ui/admin/entitlements/create_edit/commons.dart';
import 'package:frontend/ui/admin/entitlements/view/previous_consumptions/previous_consumptions_tab_content.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

class EntitlementViewContent extends StatelessWidget {
  const EntitlementViewContent({super.key, required this.entitlement, required this.cause, this.history});

  final Entitlement entitlement;
  final EntitlementCause cause;
  final List<AuditItem>? history;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    AppLocalizations lang = AppLocalizations.of(context)!;

    return SizedBox(
      width: smallContentWidth,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(lang.entitlement_cause, style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
          ),
          mediumVerticalSpacer(),
          criteriaSelectionRow(context, 'Ansuchgrund', field: entitlementInfoText(context, cause.name)),
          largeVerticalSpacer(),
          Align(
            alignment: Alignment.centerLeft,
            child:
                Text(lang.entitlement_criterias, style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
          ),
          mediumVerticalSpacer(),
          ...entitlement.values.map((value) {
            String? name = cause.criterias.firstWhereOrNull((criteria) => criteria.id == value.criteriaId)?.name;

            return Padding(
              padding: EdgeInsets.symmetric(vertical: smallPadding),
              child: criteriaSelectionRow(context, name ?? 'kein Name vorhanden',
                  field: entitlementInfoText(context, value.value)),
            );
          }),
          mediumVerticalSpacer(),
          const Divider(),
          mediumVerticalSpacer(),
          TabContainer(
            tabs: [
              OflTab(
                  label: 'Vergangene Bezüge', content: PreviousConsumptionsTabContent(entitlementId: entitlement.id)),
              OflTab(label: 'Audit Log', content: auditLogContent(context, history))
            ],
          ),
          mediumVerticalSpacer(),
        ],
      ),
    );
  }

  Widget entitlementInfoText(BuildContext context, String text) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Text(text, style: textTheme.bodyMedium, textAlign: TextAlign.right);
  }
}
