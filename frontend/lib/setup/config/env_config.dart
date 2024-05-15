import 'package:flutter_dotenv/flutter_dotenv.dart';
class EnvConfig {
  final String appName;
  final String apiRootUrl;
  final String oauthRealm;
  final String oauthClientId;

  EnvConfig(this.appName, this.apiRootUrl, this.oauthRealm, this.oauthClientId);

  static EnvConfig fromDotenv() {
    return EnvConfig(
      dotenv.env['APP_NAME']!,
      dotenv.env['API_BASE_URL']!,
      dotenv.env['OAUTH_REALM']!,
      dotenv.env['OAUTH_CLIENT_ID']!,
    );
  }
}

EnvConfig configLocal = EnvConfig(
  'OpenFastLane (Local)',
  'http://localhost:8080/api',
  'openfastlane-local',
  'ofl-admin',
);
