import '../../../auth/data/models/user.dart';
import 'distribuidor_stats.dart';

class DistribuidorDetalle {
  final User usuario;
  final DistribuidorStats estadisticas;

  /// Lista cruda de pedidos (por ahora la dejamos como Map,
  /// luego la convertiremos a un modelo Pedido específico)
  final List<Map<String, dynamic>> pedidos;

  const DistribuidorDetalle({
    required this.usuario,
    required this.estadisticas,
    required this.pedidos,
  });

  factory DistribuidorDetalle.fromJson(Map<String, dynamic> j) {
    final pedidosBlock = j['pedidos'] as Map<String, dynamic>?;
    final pedidosList = (pedidosBlock?['data'] ?? []) as List;

    return DistribuidorDetalle(
      usuario: User.fromJson(j['usuario'] as Map<String, dynamic>),
      estadisticas: DistribuidorStats.fromJson(
        j['estadisticas'] as Map<String, dynamic>,
      ),
      pedidos: pedidosList
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }
}
