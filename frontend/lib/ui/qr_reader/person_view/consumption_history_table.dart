import 'package:flutter/material.dart';
import 'package:frontend/domain/entitlements/consumption/consumption.dart';

class ConsumptionHistoryItem {
  final String text;
  final String date;

  ConsumptionHistoryItem(this.text, this.date);

  static List<ConsumptionHistoryItem> fromList(List<Consumption> items) {
    // todo
    return items
        .map((item) => ConsumptionHistoryItem(
              '${item.entitlementCauseId} - ${item.campaignId} - ${item.personId}',
              item.consumedAt.toString(),
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
              ...items.map((item) => buildTableRow(item)),
            ],
          ),
        ));
  }

  TableRow buildTableRow(ConsumptionHistoryItem item) {
    return TableRow(
      children: <Widget>[
        tableValue(item.text),
        tableValue(item.date),
      ],
    );
  }

  Widget tableValue(String value) {
    return Text(value, style: const TextStyle(fontWeight: FontWeight.normal));
  }
}
