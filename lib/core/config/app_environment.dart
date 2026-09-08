enum EnvironmentType { dev, test, prod }

class AppEnvironment {
  const AppEnvironment._();

  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'MediaPlayer',
  );

  static const String environmentRaw = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.mediaplayer.com',
  );

  static const bool enableLogging = bool.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: true,
  );

  static EnvironmentType get current {
    switch (environmentRaw.toLowerCase()) {
      case 'production':
      case 'prod':
        return EnvironmentType.prod;
      case 'testing':
      case 'test':
        return EnvironmentType.test;
      case 'development':
      case 'dev':
      default:
        return EnvironmentType.dev;
    }
  }

  static bool get isProd => current == EnvironmentType.prod;
  static bool get isDev => current == EnvironmentType.dev;
  static bool get isTest => current == EnvironmentType.test;
}
