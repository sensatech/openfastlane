import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/entitlements/consumption/consumption.dart';
import 'package:frontend/ui/commons/values/date_format.dart';

class PreviousConsumptionsTabContent extends StatelessWidget {
  const PreviousConsumptionsTabContent({
    super.key,
    required this.consumptions,
    required this.campaignName,
  });

  final List<Consumption> consumptions;
  final String campaignName;

  @override
  Widget build(BuildContext context) {
    // AppLocalizations lang = AppLocalizations.of(context)!;

    List<DataRow> list = [];

    if (consumptions.isNotEmpty) {
      list = consumptions
          .map((item) => DataRow(
                cells: [
                  DataCell(Text(formatDateShort(context, item.consumedAt) ?? 'Datum unbekannt')),
                  DataCell(Text(campaignName)),
                ],
              ))
          .toList();
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DataTable(columns: const [
            DataColumn(label: Text('Datum des Bezugs')),
            DataColumn(label: Text('Kampagne')),
          ], rows: list),
        ],
      ),
    );
  }

  Center centeredHeader(BuildContext context, String text) {
    return Center(
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Center centeredText(BuildContext context, String text, {Color? color}) {
    return Center(
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: color)),
    );
  }
}
