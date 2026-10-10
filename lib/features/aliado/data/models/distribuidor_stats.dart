class DistribuidorStats {
  final int totalPedidos;
  final int pedidosPendientes;
  final int pedidosCompletados;
  final double deudaTotal;

  const DistribuidorStats({
    required this.totalPedidos,
    required this.pedidosPendientes,
    required this.pedidosCompletados,
    required this.deudaTotal,
  });

  factory DistribuidorStats.fromJson(Map<String, dynamic> j) =>
      DistribuidorStats(
        totalPedidos: (j['total_pedidos'] ?? 0) as int,
        pedidosPendientes: (j['pedidos_pendientes'] ?? 0) as int,
        pedidosCompletados: (j['pedidos_completados'] ?? 0) as int,
        deudaTotal: ((j['deuda_total'] ?? 0) as num).toDouble(),
      );
}
