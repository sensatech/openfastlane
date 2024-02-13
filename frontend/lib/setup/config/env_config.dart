class EnvConfig {
  final String appName;
  final String apiRootUrl;
  final String oauthRealm;
  final String oauthClientId;

  EnvConfig(this.appName, this.apiRootUrl, this.oauthRealm, this.oauthClientId);
}

// EnvConfig configProd = EnvConfig('Konekta Web Admin', 'https://amigobox.at/platform', "amigobox");
EnvConfig configStaging = EnvConfig(
  'OpenFastsLane (Staging)',
  '<insert staging root url>',
  "amigobox-staging",
  "konekta-admin",
);

EnvConfig configDev = EnvConfig(
  'Konekta Web Admin (Local)',
  // 'http://10.24.9.213:8080/platform',
  'http://localhost:8080/platform',
  "amigobox-local",
  "konekta-admin",
);

class AppConfig {
  final String appName;
  final String appId;
  final bool debug;

  AppConfig(this.appName, this.appId, this.debug);
}

AppConfig appPreview =
    AppConfig('OpenFastLane PREVIEW', "at.sensatech.konekta.admin.preview", false);
