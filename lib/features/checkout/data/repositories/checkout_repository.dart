import '../../../../core/network/dio_client.dart';
import '../../../carrito/data/models/cart_item.dart';
import '../models/carrito_calculado.dart';
import '../models/cliente_destino.dart';
import '../models/pedido_creado.dart';

class CheckoutRepository {
  final _dio = DioClient.instance.dio;

  /// POST /carrito/calcular — devuelve el carrito con IVA y totales
  Future<CarritoCalculado> calcularCarrito(List<CartItem> items) async {
    final r = await _dio.post(
      '/carrito/calcular',
      data: {'items': items.map((e) => e.toApiJson()).toList()},
    );
    final data = DioClient.unwrap(r);
    if (data is! Map) {
      throw Exception('Formato inesperado en /carrito/calcular');
    }
    return CarritoCalculado.fromJson(Map<String, dynamic>.from(data));
  }

  /// POST /checkout — consumidor, profesional, negocio
  Future<PedidoCreado> crearPedido({
    required List<CartItem> items,
    required String numeroReferencia,
    required double monto,
    required String fechaPago, // YYYY-MM-DD
    required String cedulaIdentidad,
    required String bancoOrigen,
    required String bancoDestino,
    required String direccionEnvio,
    String? notas,
    ClienteDestino? clienteDestino,
  }) async {
    final payload = <String, dynamic>{
      'items': items.map((e) => e.toApiJson()).toList(),
      'metodo_pago': 'Pago Móvil',
      'numero_referencia': numeroReferencia,
      'monto': monto,
      'fecha_pago': fechaPago,
      'cedula_identidad': cedulaIdentidad,
      'banco_origen': bancoOrigen,
      'banco_destino': bancoDestino,
      'direccion_envio': direccionEnvio,
      if (notas != null && notas.isNotEmpty) 'notas': notas,
      if (clienteDestino != null) 'cliente_destino': clienteDestino.toJson(),
    };

    final r = await _dio.post('/checkout', data: payload);
    final data = DioClient.unwrap(r);
    if (data is! Map) {
      throw Exception('Formato inesperado en /checkout');
    }
    return PedidoCreado.fromJson(Map<String, dynamic>.from(data));
  }

  /// POST /checkout/credito — distribuidor
  Future<PedidoCreado> crearPedidoCredito({
    required List<CartItem> items,
    required String direccionEnvio,
    String? notas,
  }) async {
    final r = await _dio.post(
      '/checkout/credito',
      data: {
        'items': items.map((e) => e.toApiJson()).toList(),
        'direccion_envio': direccionEnvio,
        if (notas != null && notas.isNotEmpty) 'notas': notas,
        'acepto_terminos': true,
      },
    );
    final data = DioClient.unwrap(r);
    if (data is! Map) {
      throw Exception('Formato inesperado en /checkout/credito');
    }
    return PedidoCreado.fromJson(Map<String, dynamic>.from(data));
  }
}
