import 'package:frontend/domain/reports/download_file.dart';
import 'package:frontend/domain/reports/exports_api.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

class ReportsService {
  final ExportsApi reportsApi;

  ReportsService(this.reportsApi);

  Logger logger = getLogger();

  Future<DownloadFile?> createReport({
    DateTime? from,
    DateTime? to,
  }) async {
    logger.i('fetching all persons');
    final file = await reportsApi.getXlsExport(
      from: from?.toIso8601String().substring(0, 10),
      to: to?.toIso8601String().substring(0, 10),
    );
    return file;
  }
}
