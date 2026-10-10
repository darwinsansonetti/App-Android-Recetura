import 'dart:convert';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/user.dart';

class AuthRepository {
  final _dio = DioClient.instance.dio;

  /// Login (todos los roles menos admin)
  Future<User> login({required String email, required String password}) async {
    final r = await _dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    final data = DioClient.unwrap(r) as Map<String, dynamic>;

    final token = data['token'] as String;
    final user = User.fromJson(data['user'] as Map<String, dynamic>);

    await SecureStorage.saveToken(token);
    await SecureStorage.saveUserJson(jsonEncode(user.toJson()));
    return user;
  }

  /// Registro público (solo consumidor)
  Future<User> register({
    required String name,
    String? apellido,
    required String email,
    required String password,
    String? telefono,
    String? celular,
    String? documentoIdentidad,
    String? fechaNacimiento,
    String? genero,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
      if (apellido != null && apellido.isNotEmpty) 'apellido': apellido,
      if (telefono != null && telefono.isNotEmpty) 'telefono': telefono,
      if (celular != null && celular.isNotEmpty) 'celular': celular,
      if (documentoIdentidad != null && documentoIdentidad.isNotEmpty)
        'documento_identidad': documentoIdentidad,
      if (fechaNacimiento != null && fechaNacimiento.isNotEmpty)
        'fecha_nacimiento': fechaNacimiento,
      if (genero != null && genero.isNotEmpty) 'genero': genero,
    };

    final r = await _dio.post(ApiEndpoints.register, data: payload);
    final data = DioClient.unwrap(r) as Map<String, dynamic>;

    final token = data['token'] as String;
    final user = User.fromJson(data['user'] as Map<String, dynamic>);

    await SecureStorage.saveToken(token);
    await SecureStorage.saveUserJson(jsonEncode(user.toJson()));
    return user;
  }

  /// Devuelve el usuario actual (si el token es válido)
  Future<User> me() async {
    final r = await _dio.get(ApiEndpoints.me);
    final data = DioClient.unwrap(r) as Map<String, dynamic>;
    final user = User.fromJson(data);
    await SecureStorage.saveUserJson(jsonEncode(user.toJson()));
    return user;
  }

  /// Usuario cacheado localmente (para arranque rápido)
  Future<User?> cachedUser() async {
    final raw = await SecureStorage.getUserJson();
    if (raw == null) return null;
    return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiEndpoints.logout);
    } catch (_) {
      // ignoramos errores de red al cerrar sesión
    }
    await SecureStorage.clear();
  }
}
