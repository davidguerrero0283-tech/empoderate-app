/// Configuración de entornos para Empodérate
/// 
/// Define los diferentes entornos (dev/staging/prod) y sus
/// configuraciones de Firebase correspondientes.
/// 
/// Uso:
/// ```dart
/// EnvConfig.init(Environment.prod);
/// final firebaseConfig = EnvConfig.firebaseConfig;
/// ```

enum Environment {
  dev,
  staging,
  prod,
}

class EnvConfig {
  static Environment _current = Environment.dev;
  
  static Environment get current => _current;
  
  /// Inicializar el entorno
  /// Debe llamarse en main() antes de runApp()
  static void init(Environment env) {
    _current = env;
  }
  
  /// Configuración de Firebase por entorno
  static Map<String, String> get firebaseConfig {
    switch (_current) {
      case Environment.dev:
        return {
          'apiKey': const String.fromEnvironment('FIREBASE_API_KEY_DEV',
              defaultValue: 'YOUR_DEV_API_KEY'),
          'authDomain': 'empoderate-dev.firebaseapp.com',
          'projectId': 'empoderate-dev',
          'storageBucket': 'empoderate-dev.appspot.com',
          'messagingSenderId': '123456789',
          'appId': '1:123456789:web:abc123',
        };
      
      case Environment.staging:
        return {
          'apiKey': const String.fromEnvironment('FIREBASE_API_KEY_STAGING',
              defaultValue: 'YOUR_STAGING_API_KEY'),
          'authDomain': 'empoderate-staging.firebaseapp.com',
          'projectId': 'empoderate-staging',
          'storageBucket': 'empoderate-staging.appspot.com',
          'messagingSenderId': '123456789',
          'appId': '1:123456789:web:def456',
        };
      
      case Environment.prod:
        return {
          'apiKey': const String.fromEnvironment('FIREBASE_API_KEY_PROD',
              defaultValue: 'YOUR_PROD_API_KEY'),
          'authDomain': 'empoderate.firebaseapp.com',
          'projectId': 'empoderate-prod',
          'storageBucket': 'empoderate-prod.appspot.com',
          'messagingSenderId': '987654321',
          'appId': '1:987654321:web:ghi789',
        };
    }
  }
  
  /// URL de las Cloud Functions por entorno
  static String get functionsBaseUrl {
    switch (_current) {
      case Environment.dev:
        return const String.fromEnvironment('FUNCTIONS_URL_DEV',
            defaultValue: 'http://localhost:5001/empoderate-dev/us-central1');
      case Environment.staging:
        return const String.fromEnvironment('FUNCTIONS_URL_STAGING',
            defaultValue: 'https://us-central1-empoderate-staging.cloudfunctions.net');
      case Environment.prod:
        return const String.fromEnvironment('FUNCTIONS_URL_PROD',
            defaultValue: 'https://us-central1-empoderate-prod.cloudfunctions.net');
    }
  }
  
  /// Sentry DSN por entorno
  static String get sentryDsn {
    return const String.fromEnvironment('SENTRY_DSN',
        defaultValue: '');
  }
  
  /// URLs de la aplicación
  static String get appUrl {
    switch (_current) {
      case Environment.dev:
        return 'http://localhost:8080';
      case Environment.staging:
        return 'https://staging.empoderate.com';
      case Environment.prod:
        return 'https://app.empoderate.com';
    }
  }
  
  static String get blogUrl {
    switch (_current) {
      case Environment.dev:
        return 'http://localhost:8080/blog';
      case Environment.staging:
        return 'https://staging.empoderate.com/blog';
      case Environment.prod:
        return 'https://empoderate.com/blog';
    }
  }
  
  /// Versión de la app
  static const String appVersion = '1.0.0';
  
  /// Habilita logs de debug
  static bool get enableDebugLogs => _current != Environment.prod;
  
  /// Habilita analytics
  static bool get enableAnalytics => _current == Environment.prod;
}
