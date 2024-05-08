import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/domain/audit_item.dart';
import 'package:frontend/ui/commons/values/date_format.dart';

Widget auditLogContent(BuildContext context, List<AuditItem>? audit) {
  AppLocalizations lang = AppLocalizations.of(context)!;

  List<DataRow> list = [];

  if (audit != null && audit.isNotEmpty) {
    list = audit
        .map((item) => DataRow(
              cells: [
                DataCell(Text(
                  formatDateTimeShort(context, item.dateTime) ?? lang.unknown,
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
        columns: [
          DataColumn(label: Text(lang.date)),
          DataColumn(label: Text(lang.user)),
          DataColumn(label: Text(lang.action)),
        ],
        rows: list,
      ),
    ],
  ));
}
