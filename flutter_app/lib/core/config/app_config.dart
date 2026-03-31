class AppConfig {
  // Keep backend URL overridable at build/runtime:
  // flutter run --dart-define=API_BASE_URL=http://host:8000
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://95.81.124.133:8000',
  );

  // Optional OAuth client IDs can be supplied via dart-define.
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );
}
