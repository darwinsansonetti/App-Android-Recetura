import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/models/user.dart';
import '../../data/models/dashboard_data.dart';
import '../../data/models/distribuidor_detalle.dart';
import '../../data/repositories/aliado_repository.dart';

final aliadoRepositoryProvider = Provider<AliadoRepository>(
  (_) => AliadoRepository(),
);

/// Filtro de fechas del dashboard
class DashboardFiltro {
  final DateTime fechaInicio;
  final DateTime fechaFin;

  const DashboardFiltro({required this.fechaInicio, required this.fechaFin});

  /// Default: inicio del mes actual → hoy
  factory DashboardFiltro.defaultValue() {
    final now = DateTime.now();
    return DashboardFiltro(
      fechaInicio: DateTime(now.year, now.month, 1),
      fechaFin: now,
    );
  }

  String get fechaInicioStr => _fmt(fechaInicio);
  String get fechaFinStr => _fmt(fechaFin);

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DashboardFiltro copyWith({DateTime? fechaInicio, DateTime? fechaFin}) =>
      DashboardFiltro(
        fechaInicio: fechaInicio ?? this.fechaInicio,
        fechaFin: fechaFin ?? this.fechaFin,
      );
}

final dashboardFiltroProvider = StateProvider<DashboardFiltro>(
  (_) => DashboardFiltro.defaultValue(),
);

/// Dashboard (stats + pedidos) con filtro de fecha
final dashboardProvider = FutureProvider.autoDispose<DashboardData>((ref) {
  final filtro = ref.watch(dashboardFiltroProvider);
  return ref
      .read(aliadoRepositoryProvider)
      .getDashboard(
        fechaInicio: filtro.fechaInicioStr,
        fechaFin: filtro.fechaFinStr,
      );
});

// ============ Distribuidores (igual que antes) ============

final distribuidoresSearchProvider = StateProvider<String>((_) => '');

final distribuidoresListProvider = FutureProvider.autoDispose<List<User>>((
  ref,
) async {
  final buscar = ref.watch(distribuidoresSearchProvider);
  return ref
      .read(aliadoRepositoryProvider)
      .getDistribuidores(buscar: buscar.isEmpty ? null : buscar);
});

final distribuidorDetalleProvider = FutureProvider.autoDispose
    .family<DistribuidorDetalle, int>((ref, id) {
      return ref.read(aliadoRepositoryProvider).getDetalle(id);
    });
