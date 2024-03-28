import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/ui/admin/commons/admin_values.dart';
import 'package:frontend/ui/admin/commons/tab_container.dart';
import 'package:frontend/ui/admin/entitlements/commons.dart';
import 'package:frontend/ui/admin/entitlements/view/previous_consumptions/previous_consumptions_tab_content.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

class EntitlementViewContent extends StatelessWidget {
  const EntitlementViewContent({super.key, required this.entitlement, required this.cause});

  final Entitlement entitlement;
  final EntitlementCause cause;

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
          entitlementInfoRow(context, 'Ansuchgrund',
              field: entitlementInfoText(context, cause.name ?? 'kein Name vorhanden')),
          largeVerticalSpacer(),
          Align(
            alignment: Alignment.centerLeft,
            child:
                Text(lang.entitlement_criterias, style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
          ),
          mediumVerticalSpacer(),
          ...entitlement.values.map((e) => Padding(
                padding: EdgeInsets.symmetric(vertical: smallPadding),
                child: entitlementInfoRow(context, e.value, field: entitlementInfoText(context, e.value)),
              )),
          mediumVerticalSpacer(),
          const Divider(),
          mediumVerticalSpacer(),
          TabContainer(
            tabs: [
              OflTab(label: 'Vergangene Bezüge', content: PreviousConsumptionsTabContent(entitlementCauseId: cause.id)),
              OflTab(label: 'Audit Log', content: Placeholder())
            ],
          ),
          mediumVerticalSpacer(),
        ],
      ),
    );
  }
}
