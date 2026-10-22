import '../../../../core/network/dio_client.dart';

class SypagoRepository {
  final _dio = DioClient.instance.dio;

  /// POST /pagos/sypago/{pedidoId}/solicitar-otp
  Future<void> solicitarOtp({
    required int pedidoId,
    required String documentoTipo,
    required String documentoNumero,
    required String bancoCodigo,
    required String cuentaTipo,
    required String cuentaNumero,
  }) async {
    await _dio.post(
      '/pagos/sypago/$pedidoId/solicitar-otp',
      data: {
        'documento_tipo': documentoTipo,
        'documento_numero': documentoNumero,
        'banco_codigo': bancoCodigo,
        'cuenta_tipo': cuentaTipo,
        'cuenta_numero': cuentaNumero,
      },
    );
  }

  /// POST /pagos/sypago/{pedidoId}/cobrar
  /// Devuelve el transaction_id
  Future<String> cobrar({
    required int pedidoId,
    required String otp,
    required String clienteNombre,
  }) async {
    final r = await _dio.post(
      '/pagos/sypago/$pedidoId/cobrar',
      data: {'otp': otp, 'cliente_nombre': clienteNombre},
    );
    final data = DioClient.unwrap(r);
    if (data is! Map) {
      throw Exception('Formato inesperado en cobrar');
    }
    final transactionId = data['transaction_id'] as String?;
    if (transactionId == null) {
      throw Exception('No se recibió transaction_id');
    }
    return transactionId;
  }

  /// GET /pagos/sypago/{transactionId}/estado
  /// Consulta directa a SyPago (más rápido que esperar el webhook)
  Future<Map<String, dynamic>> consultarEstado(String transactionId) async {
    final r = await _dio.get('/pagos/sypago/$transactionId/estado');
    final data = DioClient.unwrap(r);
    if (data is! Map) {
      throw Exception('Formato inesperado en estado');
    }
    return Map<String, dynamic>.from(data);
  }
}
