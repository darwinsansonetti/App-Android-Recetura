import '../../../../core/network/dio_client.dart';
import '../models/estado_cuenta.dart';

class PagosRepository {
  final _dio = DioClient.instance.dio;

  /// GET /pagos/{pedidoId} — estado de cuenta
  Future<EstadoCuenta> getEstadoCuenta(int pedidoId) async {
    final r = await _dio.get('/pagos/$pedidoId');
    final data = DioClient.unwrap(r);
    if (data is! Map) {
      throw Exception('Formato inesperado en /pagos/$pedidoId');
    }
    return EstadoCuenta.fromJson(Map<String, dynamic>.from(data));
  }

  /// POST /pagos/{pedidoId} — reportar pago
  /// Devuelve el `transaccion_id`
  Future<int> reportarPago({
    required int pedidoId,
    required String numeroReferencia,
    required double monto,
    required String fechaPago, // YYYY-MM-DD
    required String cedulaIdentidad,
    required String bancoOrigen,
    required String bancoDestino,
    String? notas,
  }) async {
    final r = await _dio.post(
      '/pagos/$pedidoId',
      data: {
        'numero_referencia': numeroReferencia,
        'monto': monto,
        'fecha_pago': fechaPago,
        'cedula_identidad': cedulaIdentidad,
        'banco_origen': bancoOrigen,
        'banco_destino': bancoDestino,
        if (notas != null && notas.isNotEmpty) 'notas': notas,
      },
    );
    final data = DioClient.unwrap(r);
    if (data is! Map) {
      throw Exception('Formato inesperado al reportar pago');
    }
    return (data['transaccion_id'] ?? 0) as int;
  }
}
