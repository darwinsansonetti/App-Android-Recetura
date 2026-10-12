class EstadoCuenta {
  final int pedidoId;
  final String numeroPedido;
  final double total;
  final double totalPagadoUsd;
  final double saldoPendienteUsd;
  final bool estaPagado;
  final bool puedePagar;
  final bool puedePagarConDescuento;
  final double montoDescuento;
  final double totalConDescuento;
  final int diasRestantesDescuento;
  final bool tienePagoPendiente;

  const EstadoCuenta({
    required this.pedidoId,
    required this.numeroPedido,
    required this.total,
    required this.totalPagadoUsd,
    required this.saldoPendienteUsd,
    required this.estaPagado,
    required this.puedePagar,
    required this.puedePagarConDescuento,
    required this.montoDescuento,
    required this.totalConDescuento,
    required this.diasRestantesDescuento,
    required this.tienePagoPendiente,
  });

  factory EstadoCuenta.fromJson(Map<String, dynamic> j) => EstadoCuenta(
    pedidoId: (j['pedido_id'] ?? 0) as int,
    numeroPedido: (j['numero_pedido'] ?? '') as String,
    total: ((j['total'] ?? 0) as num).toDouble(),
    totalPagadoUsd: ((j['total_pagado_usd'] ?? 0) as num).toDouble(),
    saldoPendienteUsd: ((j['saldo_pendiente_usd'] ?? 0) as num).toDouble(),
    estaPagado: (j['esta_pagado'] ?? false) as bool,
    puedePagar: (j['puede_pagar'] ?? false) as bool,
    puedePagarConDescuento: (j['puede_pagar_con_descuento'] ?? false) as bool,
    montoDescuento: ((j['monto_descuento'] ?? 0) as num).toDouble(),
    totalConDescuento: ((j['total_con_descuento'] ?? 0) as num).toDouble(),
    diasRestantesDescuento: (j['dias_restantes_descuento'] ?? 0) as int,
    tienePagoPendiente: (j['tiene_pago_pendiente'] ?? false) as bool,
  );
}
