import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/user.dart';
import '../models/distribuidor_detalle.dart';
import '../models/dashboard_data.dart';

class AliadoRepository {
  final _dio = DioClient.instance.dio;

  /// GET /aliado/dashboard
  Future<DashboardData> getDashboard({
    String? fechaInicio,
    String? fechaFin,
    int perPage = 15,
  }) async {
    final r = await _dio.get(
      '/aliado/dashboard',
      queryParameters: {
        if (fechaInicio != null) 'fecha_inicio': fechaInicio,
        if (fechaFin != null) 'fecha_fin': fechaFin,
        'per_page': perPage,
      },
    );
    final data = DioClient.unwrap(r);
    if (data is! Map) {
      throw Exception(
        'Formato inesperado en /aliado/dashboard: ${data.runtimeType}',
      );
    }
    return DashboardData.fromJson(Map<String, dynamic>.from(data));
  }

  /// GET /aliado/usuarios
  Future<List<User>> getDistribuidores({
    String? buscar,
    int perPage = 50,
  }) async {
    final r = await _dio.get(
      '/aliado/usuarios',
      queryParameters: {
        if (buscar != null && buscar.isNotEmpty) 'buscar': buscar,
        'per_page': perPage,
      },
    );
    final data = DioClient.unwrap(r);

    // La API puede devolver:
    // A) { data: [...], meta: {...} }  (con paginación Laravel)
    // B) [...]                          (array plano)
    final List rawList;
    if (data is Map && data['data'] is List) {
      rawList = data['data'] as List;
    } else if (data is List) {
      rawList = data;
    } else {
      throw Exception(
        'Formato inesperado en /aliado/usuarios: ${data.runtimeType}',
      );
    }

    return rawList
        .whereType<Map>()
        .map((e) => User.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// POST /aliado/usuarios
  Future<({User user, String passwordGenerado})> crearDistribuidor({
    required String name,
    String? apellido,
    required String email,
  }) async {
    final r = await _dio.post(
      '/aliado/usuarios',
      data: {
        'name': name,
        if (apellido != null && apellido.isNotEmpty) 'apellido': apellido,
        'email': email,
      },
    );
    final data = DioClient.unwrap(r);
    if (data is! Map) {
      throw Exception('Formato inesperado en crear distribuidor');
    }
    return (
      user: User.fromJson(Map<String, dynamic>.from(data['user'] as Map)),
      passwordGenerado: data['password_generado'] as String,
    );
  }

  /// GET /aliado/usuarios/{id}
  Future<DistribuidorDetalle> getDetalle(int id) async {
    final r = await _dio.get('/aliado/usuarios/$id');
    final data = DioClient.unwrap(r);
    if (data is! Map) {
      throw Exception(
        'Formato inesperado en /aliado/usuarios/$id: ${data.runtimeType}',
      );
    }
    return DistribuidorDetalle.fromJson(Map<String, dynamic>.from(data));
  }

  /// GET /aliado/usuarios/{id}/password
  Future<({String password, String nombre})?> getPasswordVisible(int id) async {
    final r = await _dio.get('/aliado/usuarios/$id/password');
    if (r.statusCode == 404) return null;
    final data = DioClient.unwrap(r);
    if (data is! Map) return null;
    return (
      password: data['password'] as String,
      nombre: (data['nombre'] ?? '') as String,
    );
  }

  /// POST /aliado/usuarios/{id}/reset-password
  Future<({String passwordGenerado, String email})> resetPassword(
    int id,
  ) async {
    final r = await _dio.post('/aliado/usuarios/$id/reset-password');
    final data = DioClient.unwrap(r);
    if (data is! Map) {
      throw Exception('Formato inesperado en reset-password');
    }
    return (
      passwordGenerado: data['password_generado'] as String,
      email: data['email'] as String,
    );
  }
}
