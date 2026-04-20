enum AppEnvironment { dev, staging, prod }

extension AppEnvironmentName on AppEnvironment {
  String get name {
    switch (this) {
      case AppEnvironment.dev:
        return 'dev';
      case AppEnvironment.staging:
        return 'staging';
      case AppEnvironment.prod:
        return 'prod';
    }
  }
}
