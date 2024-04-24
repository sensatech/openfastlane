import 'package:dio/dio.dart';
import 'package:frontend/domain/abstract_api.dart';
import 'package:frontend/domain/reports/download_file.dart';

class ExportsApi extends AbstractApi {
  ExportsApi(super.dio);

  Future<DownloadFile?> getXlsExport({
    String? from,
    String? to,
  }) async {
    const $url = '/consumptions/export';
    final data = <String, dynamic>{};
    if (from != null) data['from'] = from;
    if (to != null) data['to'] = from;
    final Response<dynamic> result = await dio.get(
      $url,
      queryParameters: data,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
      ),
    );
    if (result.statusCode! < 300) {
      final content = result.data as List<int>;
      var headers = result.headers;
      var header = headers['content-disposition'];
      final now = DateTime.now().toIso8601String().split('.')[0];
      final fromName = from?.split('.')[0] ?? '';
      final toName = to?.split('.')[0] ?? '';
      final fileName = header?[0].split('filename=')[1] ?? 'export-$fromName-$toName-$now.xlsx';
      final contentType = headers['content-type']?[0];
      return DownloadFile(
        fileName: fileName,
        contentLength: content.length,
        contentType: contentType,
        content: content,
      );
    } else {
      return null;
    }
  }
}
