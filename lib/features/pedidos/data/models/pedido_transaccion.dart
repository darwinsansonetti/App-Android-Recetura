class PedidoTransaccion {
  final int id;
  final int pedidoId;
  final String numeroReferencia;
  final double monto;
  final double montoDivisa;
  final double? tasaAplicada;
  final String fechaPago;
  final String? cedulaIdentidad;
  final String? bancoOrigen;
  final String? bancoDestino;
  final String estatus;
  final String estatusTexto;
  final String estatusColor;
  final String? comprobante;
  final String? notas;
  final DateTime? fechaAprobacion;
  final DateTime? createdAt;

  const PedidoTransaccion({
    required this.id,
    required this.pedidoId,
    required this.numeroReferencia,
    required this.monto,
    required this.montoDivisa,
    this.tasaAplicada,
    required this.fechaPago,
    this.cedulaIdentidad,
    this.bancoOrigen,
    this.bancoDestino,
    required this.estatus,
    required this.estatusTexto,
    required this.estatusColor,
    this.comprobante,
    this.notas,
    this.fechaAprobacion,
    this.createdAt,
  });

  factory PedidoTransaccion.fromJson(Map<String, dynamic> j) =>
      PedidoTransaccion(
        id: (j['id'] ?? 0) as int,
        pedidoId: (j['pedido_id'] ?? 0) as int,
        numeroReferencia: (j['numero_referencia'] ?? '') as String,
        monto: ((j['monto'] ?? 0) as num).toDouble(),
        montoDivisa: ((j['monto_divisa'] ?? 0) as num).toDouble(),
        tasaAplicada: j['tasa_aplicada'] != null
            ? (j['tasa_aplicada'] as num).toDouble()
            : null,
        fechaPago: (j['fecha_pago'] ?? '') as String,
        cedulaIdentidad: j['cedula_identidad'] as String?,
        bancoOrigen: j['banco_origen'] as String?,
        bancoDestino: j['banco_destino'] as String?,
        estatus: (j['estatus'] ?? 'pendiente') as String,
        estatusTexto: (j['estatus_texto'] ?? '') as String,
        estatusColor: (j['estatus_color'] ?? 'info') as String,
        comprobante: j['comprobante'] as String?,
        notas: j['notas'] as String?,
        fechaAprobacion: j['fecha_aprobacion'] != null
            ? DateTime.tryParse(j['fecha_aprobacion'] as String)
            : null,
        createdAt: j['created_at'] != null
            ? DateTime.tryParse(j['created_at'] as String)
            : null,
      );

  /// Color hex de Material según `estatus_color`
  int get estatusColorValue {
    switch (estatusColor) {
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
}
