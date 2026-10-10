class PedidoResumen {
  final int id;
  final String numeroPedido;
  final double subtotal;
  final double descuento;
  final double total;
  final String estado;
  final String estadoTexto;
  final String estadoColor;
  final String? metodoPago;
  final bool pagado;
  final double totalPagadoUsd;
  final double saldoPendienteUsd;
  final bool estaPagado;
  final String? pagoTexto;
  final String? pagoColor;
  final bool tieneAbonos;
  final DateTime? createdAt;

  // Distribuidor dueño del pedido
  final int distribuidorId;
  final String distribuidorNombre;
  final String distribuidorEmail;

  const PedidoResumen({
    required this.id,
    required this.numeroPedido,
    required this.subtotal,
    required this.descuento,
    required this.total,
    required this.estado,
    required this.estadoTexto,
    required this.estadoColor,
    this.metodoPago,
    required this.pagado,
    required this.totalPagadoUsd,
    required this.saldoPendienteUsd,
    required this.estaPagado,
    this.pagoTexto,
    this.pagoColor,
    required this.tieneAbonos,
    this.createdAt,
    required this.distribuidorId,
    required this.distribuidorNombre,
    required this.distribuidorEmail,
  });

  factory PedidoResumen.fromJson(Map<String, dynamic> j) {
    final user = (j['user'] ?? {}) as Map<String, dynamic>;

    return PedidoResumen(
      id: (j['id'] ?? 0) as int,
      numeroPedido: (j['numero_pedido'] ?? '') as String,
      subtotal: ((j['subtotal'] ?? 0) as num).toDouble(),
      descuento: ((j['descuento'] ?? 0) as num).toDouble(),
      total: ((j['total'] ?? 0) as num).toDouble(),
      estado: (j['estado'] ?? '') as String,
      estadoTexto: (j['estado_texto'] ?? j['estado'] ?? '') as String,
      estadoColor: (j['estado_color'] ?? 'primary') as String,
      metodoPago: j['metodo_pago'] as String?,
      pagado: (j['pagado'] ?? false) as bool,
      totalPagadoUsd: ((j['total_pagado_usd'] ?? 0) as num).toDouble(),
      saldoPendienteUsd: ((j['saldo_pendiente_usd'] ?? 0) as num).toDouble(),
      estaPagado: (j['esta_pagado'] ?? false) as bool,
      pagoTexto: j['pago_texto'] as String?,
      pagoColor: j['pago_color'] as String?,
      tieneAbonos: (j['tiene_abonos'] ?? false) as bool,
      createdAt: j['created_at'] != null
          ? DateTime.tryParse(j['created_at'] as String)
          : null,
      distribuidorId: (user['id'] ?? 0) as int,
      distribuidorNombre:
          (user['nombre_completo'] ?? user['name'] ?? '') as String,
      distribuidorEmail: (user['email'] ?? '') as String,
    );
  }

  /// Convierte el `estado_color` de la API a un color de Material
  static const _colorMap = {
    'primary': 0xFF1E3A8A,
    'success': 0xFF10B981,
    'danger': 0xFFDC2626,
    'warning': 0xFFF59E0B,
    'info': 0xFF3B82F6,
    'secondary': 0xFF6B7280,
  };

  int get estadoColorValue => _colorMap[estadoColor] ?? 0xFF3B82F6;

  int get pagoColorValue => _colorMap[pagoColor ?? 'info'] ?? 0xFF3B82F6;
}
