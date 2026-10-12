import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/estado_cuenta.dart';
import '../../data/repositories/pagos_repository.dart';

final pagosRepositoryProvider = Provider<PagosRepository>(
  (_) => PagosRepository(),
);

/// Estado de cuenta de un pedido (se refetch al volver del form)
final estadoCuentaProvider = FutureProvider.autoDispose
    .family<EstadoCuenta, int>((ref, pedidoId) {
      return ref.read(pagosRepositoryProvider).getEstadoCuenta(pedidoId);
    });

/// Estado del submit del reportar pago
class ReportarPagoState {
  final bool loading;
  final String? error;
  final int? transaccionId;

  const ReportarPagoState({
    this.loading = false,
    this.error,
    this.transaccionId,
  });

  ReportarPagoState copyWith({
    bool? loading,
    String? error,
    int? transaccionId,
    bool clearError = false,
  }) => ReportarPagoState(
    loading: loading ?? this.loading,
    error: clearError ? null : (error ?? this.error),
    transaccionId: transaccionId ?? this.transaccionId,
  );
}

class ReportarPagoNotifier extends StateNotifier<ReportarPagoState> {
  final PagosRepository _repo;
  ReportarPagoNotifier(this._repo) : super(const ReportarPagoState());

  Future<int?> reportar({
    required int pedidoId,
    required String numeroReferencia,
    required double monto,
    required String fechaPago,
    required String cedulaIdentidad,
    required String bancoOrigen,
    required String bancoDestino,
    String? notas,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final id = await _repo.reportarPago(
        pedidoId: pedidoId,
        numeroReferencia: numeroReferencia,
        monto: monto,
        fechaPago: fechaPago,
        cedulaIdentidad: cedulaIdentidad,
        bancoOrigen: bancoOrigen,
        bancoDestino: bancoDestino,
        notas: notas,
      );
      state = ReportarPagoState(transaccionId: id);
      return id;
    } catch (e) {
      state = ReportarPagoState(error: e.toString());
      return null;
    }
  }
}

final reportarPagoProvider =
    StateNotifierProvider<ReportarPagoNotifier, ReportarPagoState>(
      (ref) => ReportarPagoNotifier(ref.read(pagosRepositoryProvider)),
    );
