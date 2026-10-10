import 'dashboard_stats.dart';
import 'pedido_resumen.dart';

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> j) => PaginationMeta(
    currentPage: (j['current_page'] ?? 1) as int,
    lastPage: (j['last_page'] ?? 1) as int,
    perPage: (j['per_page'] ?? 15) as int,
    total: (j['total'] ?? 0) as int,
  );
}

class DashboardData {
  final DashboardStats estadisticas;
  final List<PedidoResumen> pedidos;
  final PaginationMeta meta;

  const DashboardData({
    required this.estadisticas,
    required this.pedidos,
    required this.meta,
  });

  factory DashboardData.fromJson(Map<String, dynamic> j) {
    final est = j['estadisticas'] as Map<String, dynamic>;
    final pedidosBlock = j['pedidos'] as Map<String, dynamic>?;
    final pedidosList = (pedidosBlock?['data'] ?? []) as List;
    final meta = (pedidosBlock?['meta'] ?? {}) as Map<String, dynamic>;

    return DashboardData(
      estadisticas: DashboardStats.fromJson(est),
      pedidos: pedidosList
          .whereType<Map>()
          .map((e) => PedidoResumen.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      meta: PaginationMeta.fromJson(meta),
    );
  }
}
