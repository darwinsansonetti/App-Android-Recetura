class Env {
  Env._();

  /// Cambia a true al compilar con --dart-define=PROD=true
  static const bool isProd = bool.fromEnvironment('PROD', defaultValue: false);

  static const String _prodUrl = 'https://api.mrrecetura.com/api/v1';
  static const String _devUrl = 'https://api.mrrecetura.com/api/v1';

  static String get baseUrl => isProd ? _prodUrl : _devUrl;
}
