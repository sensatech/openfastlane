import 'dart:convert';

import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:frontend/domain/login/auth_result_model.dart';
import 'package:frontend/setup/config/env_config.dart';
import 'package:frontend/setup/logger.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';

class AuthService {
  final EnvConfig envConfig;

  AuthService(this.envConfig);

  static const OAUTH_HOST = 'id.amigobox.at';
  static const OAUTH_SCOPE = 'amigo_platform';

  Logger logger = getLogger();

  String get oauthRootUrlPart => '/realms/${envConfig.oauthRealm}';

  String get oauthUrlAuth => '$oauthRootUrlPart/protocol/openid-connect/auth';

  String get oauthUrlToken => '$oauthRootUrlPart/protocol/openid-connect/token';

  String get oauthUrlUserInfo => '$oauthRootUrlPart/protocol/openid-connect/userinfo';

  String? lastAccessToken;

  Future<AuthResult> connectAuth() async {
    var redirectUrlConnect = '${Uri.base.origin}/admin/auth.html';
    final startCodeFlowUrl = Uri.https(OAUTH_HOST, oauthUrlAuth, {
      'response_type': 'code',
      'client_id': envConfig.oauthClientId,
      'redirect_uri': redirectUrlConnect,
      'scope': 'email profile openid $OAUTH_SCOPE',
    });

    final result = await FlutterWebAuth.authenticate(
        url: startCodeFlowUrl.toString(), callbackUrlScheme: "ignored");
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
    logger.i("accessToken: $accessToken");

    lastAccessToken = accessToken;

    return accessTokenToResult(accessToken);
  }

  Future<AuthResult> accessTokenToResult(String accessToken) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
    logger.i("decodedToken: $decodedToken");
    var dynamicRoles = decodedToken['realm_access']['roles'] as List<dynamic>;
    List<String> roles = dynamicRoles.map((e) => e.toString()).toList();
    logger.i("decodedToken roles: $roles");

    return Future.value(
      AuthResult(
        decodedToken['given_name'] as String,
        decodedToken['family_name'] as String,
        roles,
        accessToken: accessToken,
        username: decodedToken['preferred_username'] as String,
      ),
    );
  }
}
