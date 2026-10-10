import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _kToken = 'auth_token';
  static const _kUserJson = 'user_json';

  static Future<void> saveToken(String token) =>
      _storage.write(key: _kToken, value: token);

  static Future<String?> getToken() => _storage.read(key: _kToken);

  static Future<void> saveUserJson(String json) =>
      _storage.write(key: _kUserJson, value: json);

  static Future<String?> getUserJson() => _storage.read(key: _kUserJson);

  static Future<void> clear() => _storage.deleteAll();
}
