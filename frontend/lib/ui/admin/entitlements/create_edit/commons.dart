import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/entitlements/entitlement_criteria/entitlement_criteria_model.dart';
import 'package:frontend/domain/entitlements/entitlement_value.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

double inputFieldWidth = 300;

Widget criteriaSelectionRow(BuildContext context, String title, {required Widget child}) {
  TextTheme textTheme = Theme.of(context).textTheme;

  return Row(
    children: [
      SizedBox(
        width: inputFieldWidth,
        child: Text(title, style: textTheme.bodyMedium, textAlign: TextAlign.right),
      ),
      SizedBox(width: largeSpace),
      child,
    ],
  );
}

Widget entitlementValuesTable(
  BuildContext context,
  List<EntitlementValue> entitlementValues,
  List<EntitlementCriteria> causeCriterias,
) {
  AppLocalizations lang = AppLocalizations.of(context)!;
  return Table(
    defaultColumnWidth: const IntrinsicColumnWidth(),
    children: entitlementValues.map((value) {
      String? name = causeCriterias.firstWhereOrNull((criteria) => criteria.id == value.criteriaId)?.name;
      return widgetTableRow(context, name ?? lang.name_unknown, entitlementValueText(context, value));
    }).toList(),
  );
}

TableRow widgetTableRow(BuildContext context, String label, Widget value) {
  TextTheme textTheme = Theme.of(context).textTheme;
  return TableRow(children: [
    Text(label, style: textTheme.bodyMedium, textAlign: TextAlign.left),
    const SizedBox(width: 30),
    value,
  ]);
}

TableRow textTableRow(BuildContext context, String label, String value) {
  TextTheme textTheme = Theme.of(context).textTheme;
  return widgetTableRow(context, label, Text(label, style: textTheme.bodyMedium, textAlign: TextAlign.left));
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
