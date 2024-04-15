import 'package:flutter/material.dart';
import 'package:frontend/domain/audit_item.dart';
import 'package:frontend/ui/commons/values/date_format.dart';

Widget auditLogContent(BuildContext context, List<AuditItem> history) {
  // return const Center(child: Text('Tab2 Content'));
  final list = history
      .map((item) => DataRow(
            cells: [
              DataCell(Text(getFormattedDateAsString(context, item.dateTime) ?? 'unbekannt')),
              DataCell(Text(item.user)),
              DataCell(Text(item.action)),
              DataCell(Text(item.message)),
            ],
          ))
      .toList();
  return SingleChildScrollView(
      child: DataTable(
    //TODO: l10n
    columns: const [
      DataColumn(label: Text('Datum')),
      DataColumn(label: Text('User')),
      DataColumn(label: Text('Aktion')),
      DataColumn(label: Text('Info')),
    ],
    rows: list,
  ));
}
