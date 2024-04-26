import 'package:flutter/material.dart';
import 'package:frontend/domain/audit_item.dart';
import 'package:frontend/ui/commons/values/date_format.dart';

Widget auditLogContent(BuildContext context, List<AuditItem>? audit) {
  List<DataRow> list = [];

  if (audit != null && audit.isNotEmpty) {
    list = audit
        .map((item) => DataRow(
              cells: [
                DataCell(Text(
                  formatDateTimeShort(context, item.dateTime) ?? 'unbekannt',
                  maxLines: 1,
                )),
                DataCell(Text(item.user)),
                DataCell(Text(item.action))
              ],
            ))
        .toList();
  }

  return SingleChildScrollView(
      child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      DataTable(
        //TODO: l10n
        columns: const [
          DataColumn(label: Text('Datum')),
          DataColumn(label: Text('User')),
          DataColumn(label: Text('Aktion')),
        ],
        rows: list,
      ),
    ],
  ));
}
