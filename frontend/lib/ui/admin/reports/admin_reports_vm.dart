import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/reports/download_file.dart';
import 'package:frontend/domain/reports/reports_service.dart';
import 'package:frontend/setup/logger.dart';
import 'package:frontend/ui/admin/persons/admin_person_list_vm.dart';
import 'package:frontend/ui/commons/values/date_format.dart';
import 'package:logger/logger.dart';
import 'package:universal_html/html.dart';

class AdminReportsViewModel extends Cubit<PersonListState> {
  AdminReportsViewModel(this._reportsService) : super(PersonListInitial());

  final ReportsService _reportsService;

  Logger logger = getLogger();

  Future<Object?> prepareReportDownload(
    BuildContext context, {
    String? from,
    String? to,
  }) async {
    try {
      final DownloadFile? file = await _reportsService.createReport(
        from: getDateOrNull(context, from),
        to: getDateOrNull(context, to),
      );

      logger.d('prepareReportDownload: retrieved $file');

      if (file == null || file.content.isEmpty) {
        return false;
      }
      // create link
      final base64data = base64Encode(file.content);
      final dataType = file.contentType ?? 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      final link = AnchorElement(href: 'data:$dataType;base64,$base64data');

      logger.i('prepareReportDownload: create link for ${file.fileName} $dataType');

      link.download = file.fileName;
      link.click();

      logger.d('prepareReportDownload: iterating $file persons');
      return file;
    } catch (e) {
      return null;
    }
  }

  DateTime? getDateOrNull(BuildContext context, String? value) {
    if (value == null) {
      return null;
    } else {
      try {
        return getFormattedDateTime(context, value);
      } catch (e) {
        return null;
      }
    }
  }
}
