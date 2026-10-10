class DashboardStats {
  final String fechaInicio;
  final String fechaFin;
  final int totalPedidos;
  final int pedidosAprobados;
  final int pedidosRechazados;
  final double montoAprobados;

  const DashboardStats({
    required this.fechaInicio,
    required this.fechaFin,
    required this.totalPedidos,
    required this.pedidosAprobados,
    required this.pedidosRechazados,
    required this.montoAprobados,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> j) => DashboardStats(
    fechaInicio: (j['fecha_inicio'] ?? '') as String,
    fechaFin: (j['fecha_fin'] ?? '') as String,
    totalPedidos: (j['total_pedidos'] ?? 0) as int,
    pedidosAprobados: (j['pedidos_aprobados'] ?? 0) as int,
    pedidosRechazados: (j['pedidos_rechazados'] ?? 0) as int,
    montoAprobados: ((j['monto_aprobados'] ?? 0) as num).toDouble(),
  );
}
