class PedidoCreado {
  final int id;
  final String numeroPedido;
  final double subtotal;
  final double descuento;
  final double total;
  final String estado;
  final String? metodoPago;

  const PedidoCreado({
    required this.id,
    required this.numeroPedido,
    required this.subtotal,
    required this.descuento,
    required this.total,
    required this.estado,
    this.metodoPago,
  });

  factory PedidoCreado.fromJson(Map<String, dynamic> j) => PedidoCreado(
    id: (j['id'] ?? 0) as int,
    numeroPedido: (j['numero_pedido'] ?? '') as String,
    subtotal: ((j['subtotal'] ?? 0) as num).toDouble(),
    descuento: ((j['descuento'] ?? 0) as num).toDouble(),
    total: ((j['total'] ?? 0) as num).toDouble(),
    estado: (j['estado'] ?? 'pendiente') as String,
    metodoPago: j['metodo_pago'] as String?,
  );
}
