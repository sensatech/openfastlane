import 'package:frontend/setup/logger.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';

class AuthResult {
  final String username;
  final String firstName;
  final String lastName;
  final List<String> roles;
  final String accessToken;
  final String refreshToken;

  final String? idToken;
  final int? expiresAtSeconds;

  static Logger logger = getLogger();

  AuthResult(
      {required this.username,
      required this.firstName,
      required this.lastName,
      required this.roles,
      required this.accessToken,
      required this.refreshToken,
      this.idToken,
      required this.expiresAtSeconds});


  static Future<AuthResult> accessTokenToResult({
    required String accessToken,
    required String refreshToken,
    String? idToken,
  }) async {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
    logger.i('decodedToken: $decodedToken');
    var dynamicRoles = decodedToken['realm_access']['roles'] as List<dynamic>;
    List<String> roles = dynamicRoles.map((e) => e.toString()).where((element) => element.startsWith('OFL_')).toList();
    final expiresAt = decodedToken['exp'] as int?;
    // logger.i('parsedAccessToken: $parsedAccessToken');
    logger.i('expiresAt: ${DateTime.fromMillisecondsSinceEpoch(expiresAt! * 1000)}');
    return Future.value(AuthResult(
      firstName: decodedToken['given_name'] as String,
      lastName: decodedToken['family_name'] as String,
      roles: roles,
      accessToken: accessToken,
      expiresAtSeconds: expiresAt,
      refreshToken: refreshToken,
      idToken: idToken,
      username: decodedToken['preferred_username'] as String,
    ));
  }
}
