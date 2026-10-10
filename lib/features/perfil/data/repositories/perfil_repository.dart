import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/data/models/user.dart';

class PerfilRepository {
  final _dio = DioClient.instance.dio;

  /// GET /perfil — devuelve el usuario completo
  Future<User> getPerfil() async {
    final r = await _dio.get(ApiEndpoints.perfil);
    final data = DioClient.unwrap(r);
    if (data is! Map) {
      throw Exception('Formato inesperado en /perfil');
    }
    return User.fromJson(Map<String, dynamic>.from(data));
  }

  /// PUT /perfil — actualiza datos personales (todos opcionales)
  Future<User> actualizarPerfil({
    String? name,
    String? apellido,
    String? telefono,
    String? celular,
    String? documentoIdentidad,
    String? fechaNacimiento,
    String? genero,
    String? direccion,
    String? ciudad,
    String? estadoProvincia,
    String? pais,
    String? codigoPostal,
  }) async {
    final payload = <String, dynamic>{
      if (name != null && name.isNotEmpty) 'name': name,
      if (apellido != null && apellido.isNotEmpty) 'apellido': apellido,
      if (telefono != null && telefono.isNotEmpty) 'telefono': telefono,
      if (celular != null && celular.isNotEmpty) 'celular': celular,
      if (documentoIdentidad != null && documentoIdentidad.isNotEmpty)
        'documento_identidad': documentoIdentidad,
      if (fechaNacimiento != null && fechaNacimiento.isNotEmpty)
        'fecha_nacimiento': fechaNacimiento,
      if (genero != null && genero.isNotEmpty) 'genero': genero,
      if (direccion != null && direccion.isNotEmpty) 'direccion': direccion,
      if (ciudad != null && ciudad.isNotEmpty) 'ciudad': ciudad,
      if (estadoProvincia != null && estadoProvincia.isNotEmpty)
        'estado_provincia': estadoProvincia,
      if (pais != null && pais.isNotEmpty) 'pais': pais,
      if (codigoPostal != null && codigoPostal.isNotEmpty)
        'codigo_postal': codigoPostal,
    };

    final r = await _dio.put(ApiEndpoints.perfil, data: payload);
    final data = DioClient.unwrap(r);
    if (data is! Map) {
      throw Exception('Formato inesperado al actualizar perfil');
    }
    return User.fromJson(Map<String, dynamic>.from(data));
  }

  /// PUT /perfil/password
  Future<void> cambiarPassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.put(
      ApiEndpoints.perfilPassword,
      data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPassword,
      },
    );
  }

  /// PUT /perfil/distribuidor — solo rol distribuidor
  /// Devuelve el `distribuidor` actualizado
  Future<Map<String, dynamic>> actualizarDistribuidor({
    required String razonSocial,
    String? codigo,
    String? rif,
    String? zona,
    String? municipio,
    String? nacionalidad,
    bool? contribuyenteEspecial,
    String? sicm,
    String? maestro,
    String? observacion,
  }) async {
    final payload = <String, dynamic>{
      'razon_social': razonSocial,
      if (codigo != null && codigo.isNotEmpty) 'codigo': codigo,
      if (rif != null && rif.isNotEmpty) 'rif': rif,
      if (zona != null && zona.isNotEmpty) 'zona': zona,
      if (municipio != null && municipio.isNotEmpty) 'municipio': municipio,
      if (nacionalidad != null && nacionalidad.isNotEmpty)
        'nacionalidad': nacionalidad,
      if (contribuyenteEspecial != null)
        'contribuyente_especial': contribuyenteEspecial,
      if (sicm != null && sicm.isNotEmpty) 'sicm': sicm,
      if (maestro != null && maestro.isNotEmpty) 'maestro': maestro,
      if (observacion != null && observacion.isNotEmpty)
        'observacion': observacion,
    };

    final r = await _dio.put(ApiEndpoints.perfilDistribuidor, data: payload);
    final data = DioClient.unwrap(r);
    if (data is! Map) {
      throw Exception('Formato inesperado al actualizar distribuidor');
    }
    return Map<String, dynamic>.from(data);
  }
}
