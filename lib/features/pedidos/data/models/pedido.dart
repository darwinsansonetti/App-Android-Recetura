import 'pedido_detalle_item.dart';
import 'pedido_transaccion.dart';

class Pedido {
  final int id;
  final String numeroPedido;
  final double subtotal;
  final double descuento;
  final double total;
  final String estado;
  final String estadoTexto;
  final String estadoColor;
  final String? notas;
  final String? direccionEnvio;
  final String? metodoPago;

  final DateTime? completadoAt;
  final DateTime? fechaLimiteDescuento;
  final DateTime? fechaLimitePago;

  final bool pagado;
  final DateTime? pagadoAt;
  final double totalPagadoUsd;
  final double saldoPendienteUsd;
  final bool estaPagado;

  final bool puedePagar;
  final String? pagoTexto;
  final String? pagoColor;
  final bool tieneAbonos;

  final bool puedePagarConDescuento;
  final double montoDescuento;
  final double totalConDescuento;
  final int diasRestantesDescuento;

  final List<PedidoDetalleItem> detalles;
  final List<PedidoTransaccion> transacciones;
  final Map<String, dynamic>? clienteDestino;

  final DateTime? createdAt;

  const Pedido({
    required this.id,
    required this.numeroPedido,
    required this.subtotal,
    required this.descuento,
    required this.total,
    required this.estado,
    required this.estadoTexto,
    required this.estadoColor,
    this.notas,
    this.direccionEnvio,
    this.metodoPago,
    this.completadoAt,
    this.fechaLimiteDescuento,
    this.fechaLimitePago,
    required this.pagado,
    this.pagadoAt,
    required this.totalPagadoUsd,
    required this.saldoPendienteUsd,
    required this.estaPagado,
    required this.puedePagar,
    this.pagoTexto,
    this.pagoColor,
    required this.tieneAbonos,
    required this.puedePagarConDescuento,
    required this.montoDescuento,
    required this.totalConDescuento,
    required this.diasRestantesDescuento,
    required this.detalles,
    required this.transacciones,
    this.clienteDestino,
    this.createdAt,
  });

  factory Pedido.fromJson(Map<String, dynamic> j) => Pedido(
    id: (j['id'] ?? 0) as int,
    numeroPedido: (j['numero_pedido'] ?? '') as String,
    subtotal: ((j['subtotal'] ?? 0) as num).toDouble(),
    descuento: ((j['descuento'] ?? 0) as num).toDouble(),
    total: ((j['total'] ?? 0) as num).toDouble(),
    estado: (j['estado'] ?? '') as String,
    estadoTexto: (j['estado_texto'] ?? '') as String,
    estadoColor: (j['estado_color'] ?? 'info') as String,
    notas: j['notas'] as String?,
    direccionEnvio: j['direccion_envio'] as String?,
    metodoPago: j['metodo_pago'] as String?,
    completadoAt: j['completado_at'] != null
        ? DateTime.tryParse(j['completado_at'] as String)
        : null,
    fechaLimiteDescuento: j['fecha_limite_descuento'] != null
        ? DateTime.tryParse(j['fecha_limite_descuento'] as String)
        : null,
    fechaLimitePago: j['fecha_limite_pago'] != null
        ? DateTime.tryParse(j['fecha_limite_pago'] as String)
        : null,
    pagado: (j['pagado'] ?? false) as bool,
    pagadoAt: j['pagado_at'] != null
        ? DateTime.tryParse(j['pagado_at'] as String)
        : null,
    totalPagadoUsd: ((j['total_pagado_usd'] ?? 0) as num).toDouble(),
    saldoPendienteUsd: ((j['saldo_pendiente_usd'] ?? 0) as num).toDouble(),
    estaPagado: (j['esta_pagado'] ?? false) as bool,
    puedePagar: (j['puede_pagar'] ?? false) as bool,
    pagoTexto: j['pago_texto'] as String?,
    pagoColor: j['pago_color'] as String?,
    tieneAbonos: (j['tiene_abonos'] ?? false) as bool,
    puedePagarConDescuento: (j['puede_pagar_con_descuento'] ?? false) as bool,
    montoDescuento: ((j['monto_descuento'] ?? 0) as num).toDouble(),
    totalConDescuento: ((j['total_con_descuento'] ?? 0) as num).toDouble(),
    diasRestantesDescuento: (j['dias_restantes_descuento'] ?? 0) as int,
    detalles: ((j['detalles'] ?? []) as List)
        .whereType<Map>()
        .map((e) => PedidoDetalleItem.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    transacciones: ((j['transacciones'] ?? []) as List)
        .whereType<Map>()
        .map((e) => PedidoTransaccion.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    clienteDestino: j['cliente_destino'] != null
        ? Map<String, dynamic>.from(j['cliente_destino'] as Map)
        : null,
    createdAt: j['created_at'] != null
        ? DateTime.tryParse(j['created_at'] as String)
        : null,
  );

  /// Color hex de Material según `estado_color`
  int get estadoColorValue {
    switch (estadoColor) {
      case 'success':
        return 0xFF10B981;
      case 'danger':
        return 0xFFDC2626;
      case 'warning':
        return 0xFFF59E0B;
      case 'info':
        return 0xFF3B82F6;
      case 'primary':
        return 0xFF1E3A8A;
      default:
        return 0xFF6B7280;
    }
  }

  /// Ítems totales del pedido
  int get totalItems => detalles.fold(0, (sum, item) => sum + item.cantidad);
}
