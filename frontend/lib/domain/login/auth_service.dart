import 'dart:convert';

import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:frontend/domain/login/auth_result_model.dart';
import 'package:frontend/setup/config/env_config.dart';
import 'package:frontend/setup/logger.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class AuthService {
  final EnvConfig envConfig;

  AuthService(this.envConfig);

  static const String OAUTH_HOST = 'id.amigobox.at';
  static const String OAUTH_SCOPE = 'openfastlane';

  Logger logger = getLogger();

  String get oauthRootUrlPart => '/realms/${envConfig.oauthRealm}';

  String get oauthUrlAuth => '$oauthRootUrlPart/protocol/openid-connect/auth';

  String get oauthUrlToken => '$oauthRootUrlPart/protocol/openid-connect/token';

  String get oauthUrlUserInfo => '$oauthRootUrlPart/protocol/openid-connect/userinfo';

  Future<AuthResult> login() async {
    var redirectUrlConnect = '${Uri.base.origin}/admin/auth.html';
    final startCodeFlowUrl = Uri.https(OAUTH_HOST, oauthUrlAuth, {
      'response_type': 'code',
      'client_id': envConfig.oauthClientId,
      'redirect_uri': redirectUrlConnect,
      'scope': 'email profile openid $OAUTH_SCOPE',
    });

    final result = await FlutterWebAuth.authenticate(url: startCodeFlowUrl.toString(), callbackUrlScheme: "ignored");
    logger.i("FlutterWebAuth.authenticate result: $result");

    final code = Uri.parse(result).queryParameters['code'] ?? '';
    logger.i("code: $code");

    var oauthTokenUrl = Uri.https(OAUTH_HOST, oauthUrlToken);
    logger.i("fetch: $oauthTokenUrl");

    final oauthTokenResponse = await http.post(
      oauthTokenUrl,
      body: {
        'client_id': envConfig.oauthClientId,
        'redirect_uri': redirectUrlConnect,
        'grant_type': 'authorization_code',
        'code': code,
      },
    );

    // Get the access token from the response
    logger.i("auth response: ${oauthTokenResponse.body}");
    var tokenObjects = jsonDecode(oauthTokenResponse.body);
    logger.i("tokenObjects: $tokenObjects");
    final accessToken = tokenObjects['access_token'] as String;
    final refreshToken = tokenObjects['refresh_token'] as String;
    logger.i("accessToken: $accessToken");
    logger.i("refreshToken: $refreshToken");

    return AuthResult.accessTokenToResult(accessToken: accessToken, refreshToken: refreshToken);
  }
}
