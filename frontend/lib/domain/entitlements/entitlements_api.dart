import 'package:dio/dio.dart';
import 'package:frontend/domain/abstract_api.dart';
import 'package:frontend/domain/entitlements/entitlement.dart';
import 'package:frontend/domain/entitlements/entitlement_cause/entitlement_cause_model.dart';
import 'package:frontend/domain/entitlements/entitlement_value.dart';
import 'package:frontend/domain/reports/download_file.dart';

// NOT mocked API
class EntitlementsApi extends AbstractApi {
  EntitlementsApi(super.dio);

  Future<List<Entitlement>> getAllEntitlements() async {
    const $url = '/entitlements';
    Future<List<Entitlement>> result = dioGetList($url, Entitlement.fromJson);
    return result;
  }

  Future<Entitlement> getEntitlement(String id) async {
    final $url = '/entitlements/$id';
    return dioGet($url, Entitlement.fromJson);
  }

  Future<Entitlement> createEntitlement(
      {required String personId, required String entitlementCauseId, required List<EntitlementValue> values}) async {
    const $url = '/entitlements';
    final data = <String, dynamic>{};
    data['personId'] = personId;
    data['entitlementCauseId'] = entitlementCauseId;
    data['values'] = values.map((e) => e.toJson()).toList();
    return dioPost($url, Entitlement.fromJson, data: data);
  }

  Future<Entitlement> putEntitlement({required String entitlementId, required List<EntitlementValue> values}) async {
    final $url = '/entitlements/$entitlementId';
    final data = <String, dynamic>{};
    data['values'] = values.map((e) => e.toJson()).toList();
    return dioPatch($url, Entitlement.fromJson, data: data);
  }

  Future<List<EntitlementCause>> getAllEntitlementCauses() async {
    const $url = '/entitlement-causes';
    return dioGetList($url, EntitlementCause.fromJson);
  }

  Future<EntitlementCause> getEntitlementCause(String id) async {
    final $url = '/entitlement-causes/$id';
    return dioGet($url, EntitlementCause.fromJson);
  }

  Future<Entitlement> extend(String id) async {
    final $url = '/entitlements/$id/extend';
    return dioPut($url, Entitlement.fromJson);
  }

  Future<DownloadFile?> getQrPdf(String id) async {
    final $url = '/entitlements/$id/pdf';
    final Response<dynamic> result = await dio.get(
      $url,
      options: Options(responseType: ResponseType.bytes, followRedirects: true),
    );
    if (result.statusCode! < 300) {
      final content = result.data as List<int>;
      var headers = result.headers;
      var header = headers['content-disposition'];
      final now = DateTime.now().toIso8601String().split('.')[0];
      final fileName = header?[0].split('filename=')[1] ?? 'entitlement-qr-$id.pdf';
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
