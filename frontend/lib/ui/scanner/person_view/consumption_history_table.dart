import 'package:flutter/material.dart';
import 'package:frontend/domain/entitlements/consumption/consumption.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:frontend/ui/commons/values/size_values.dart';

class ConsumptionHistoryItem {
  final String campaignName;
  final DateTime date;

  ConsumptionHistoryItem(this.campaignName, this.date);

  static List<ConsumptionHistoryItem> fromList(List<Consumption> items) {
    // todo
    return items
        .map((item) => ConsumptionHistoryItem(
              item.campaignId,
              item.consumedAt,
            ))
        .toList();
  }
}

class ConsumptionHistoryTable extends StatelessWidget {
  final List<ConsumptionHistoryItem> items;

  const ConsumptionHistoryTable({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        child: Center(
          child: Table(
            children: <TableRow>[
              ...items.map((item) => buildTableRow(context, item)),
            ],
          ),
        ));
  }

  TableRow buildTableRow(BuildContext context, ConsumptionHistoryItem item) {
    String? date;
    date = formatDateTimeLong(context, item.date);
    return TableRow(
      children: <Widget>[
        tableValue(item.campaignName, TextAlign.start),
        tableValue(date ?? '', TextAlign.end),
      ],
    );
  }

  Widget tableValue(String value, TextAlign alignment) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: smallPadding),
      child: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.normal),
        textAlign: alignment,
      ),
    );
  }
}
