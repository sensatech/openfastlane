import 'dart:io';

import 'package:dio/dio.dart';
import 'package:frontend/domain/login/global_login_service.dart';
import 'package:frontend/setup/logger.dart';
import 'package:logger/logger.dart';

Dio configureWithAuth(String baseUrl, GlobalLoginService globalLoginService) {
  final dio = Dio();
  final Logger logger = getLogger();

  dio.options.baseUrl = baseUrl;
  dio.options.connectTimeout = const Duration(seconds: 10);
  dio.options.receiveTimeout = const Duration(seconds: 20);
  dio.options.headers['content-Type'] = 'application/json';

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) async {
        logger.i('Global: checking blockingGetAccessToken for request to ${options.uri}');
        String? accessToken = await globalLoginService.blockingGetAccessToken();
        if (accessToken == null) {
          throw Exception('No access token found, must login again!');
        } else {
          options.headers[HttpHeaders.authorizationHeader] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
    ),
  );
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  return dio;
}
