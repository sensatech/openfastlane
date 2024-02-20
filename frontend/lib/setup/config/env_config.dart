class EnvConfig {
  final String appName;
  final String apiRootUrl;
  final String oauthRealm;
  final String oauthClientId;

  EnvConfig(this.appName, this.apiRootUrl, this.oauthRealm, this.oauthClientId);
}

EnvConfig configStaging = EnvConfig(
  'OpenFastLane (Staging)',
  '<insert staging root url>',
  "openfastlane-staging",
  "ofl-admin",
);

EnvConfig configLocal = EnvConfig(
  'OpenFastLane (Local)',
  'http://localhost:8080/api',
  "openfastlane-local",
  "ofl-admin",
);
