import 'package:dio/dio.dart';
import 'package:frontend/domain/rest_exception.dart';

class ApiException {
  final int statusCode;
  final int errorCode;
  final String errorName;
  final String errorMessage;

  ApiException(this.statusCode, this.errorCode, this.errorName, this.errorMessage);
}

class AbstractApi {
  final Dio dio;

  AbstractApi(this.dio);

  Future<T> dioPost<T>(
    String $url,
    T Function(Map<String, dynamic> json) fromJson, {
    Object? data,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final response = await dio.post($url, data: data, queryParameters: parameters);
      return parseResponse(response, fromJson);
    } catch (e) {
      return handleDioErrors(e);
    }
  }

  Future<void> dioPostEmpty(
    String $url, {
    Object? data,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final response = await dio.post($url, data: data, queryParameters: parameters);
      return parseStatus(response);
    } catch (e) {
      return handleDioErrors(e);
    }
  }

  Future<T> dioPatch<T>(String $url, T Function(Map<String, dynamic> json) fromJson,
      {Object? data}) async {
    try {
      final response = await dio.patch($url, data: data);
      return parseResponse(response, fromJson);
    } catch (e) {
      return handleDioErrors(e);
    }
  }

  Future<void> dioPatchEmpty(
    String $url, {
    Object? data,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final response = await dio.patch($url, data: data, queryParameters: parameters);
      return parseStatus(response);
    } catch (e) {
      return handleDioErrors(e);
    }
  }

  Future<T> dioPut<T>(String $url, T Function(Map<String, dynamic> json) fromJson,
      {Object? data}) async {
    try {
      final response = await dio.put($url, data: data);
      return parseResponse(response, fromJson);
    } catch (e) {
      return handleDioErrors(e);
    }
  }

  Future<List<T>> dioPutList<T>(String $url, T Function(Map<String, dynamic> json) fromJson,
      {Object? data}) async {
    try {
      final response = await dio.put($url, data: data);
      return parseResponseList(response, fromJson);
    } catch (e) {
      return handleDioErrors(e);
    }
  }

  Future<T> dioDelete<T>(String $url, T Function(Map<String, dynamic> json) fromJson) async {
    try {
      final response = await dio.delete($url);
      return parseResponse(response, fromJson);
    } catch (e) {
      return handleDioErrors(e);
    }
  }

  Future<List<T>> dioGetList<T>(String $url, T Function(Map<String, dynamic> json) fromJson) async {
    try {
      final response = await dio.get($url);
      return parseResponseList(response, fromJson);
    } catch (e) {
      return handleDioErrors(e);
    }
  }

  Future<T> dioGet<T>(String $url, T Function(Map<String, dynamic> json) fromJson) async {
    try {
      final response = await dio.get($url);
      return parseResponse(response, fromJson);
    } catch (e) {
      return handleDioErrors(e);
    }
  }

  Future<T> handleDioErrors<T>(Object e) {
    if (e is DioException) {
      var response = e.response;
      if (response != null) {
        return handleError(response);
      }
    }
    return Future.error(e);
  }

  Future<void> parseStatus<T>(Response<dynamic> response) {
    if (response.statusCode! >= 200 && response.statusCode! <= 300) {
      return Future.value();
    } else {
      return handleError(response);
    }
  }

  Future<T> parseResponse<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    if (response.statusCode! >= 200 && response.statusCode! <= 300) {
      var data = response.data;
      if (data is Map<String, dynamic>) {
        var dto = fromJson(data);
        return Future.value(dto);
      } else {
        if (data != null) {}
        return Future.value(null);
      }
    } else {
      return handleError(response);
    }
  }

  Future<List<T>> parseResponseList<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    if (response.statusCode! >= 200 && response.statusCode! <= 300) {
      var data = response.data;
      if (data is List<dynamic>) {
        final list = data
            .map((e) => (e is Map<String, dynamic>)
                ? fromJson(e)
                : throw ArgumentError("fromJson is meant for APIs without response!"))
            .toList();
        final notNullList = list.where((element) => element != null).toList();
        return Future.value(notNullList);
      } else {
        if (data != null) {}
        return Future.value([]);
      }
    } else {
      return handleError(response);
    }
  }

  Future<T> handleError<T>(Response<dynamic> response) {
    if (response.statusCode! >= 200 && response.statusCode! <= 300) {
      return Future.value();
    } else {
      var data = response.data;
      if (data is Map<String, dynamic>) {
        final restError = RestException.fromJson(data);
        final error = ApiException(response.statusCode ?? 400, restError.errorCode,
            restError.errorName, restError.errorMessage);
        return Future.error(error);
      }
      return Future.error("API returned $data");
    }
  }

  Future<T> buildOkFuture<T>(Response<dynamic> response) {
    if (response.statusCode! >= 200 && response.statusCode! <= 300) {
      var data = response.data;
      if (data is Map<String, dynamic>) {
        throw ArgumentError("buildOkFuture is meant for APIs without response!");
      } else {
        return Future.value();
      }
    } else {
      return handleError<T>(response);
    }
  }
}
