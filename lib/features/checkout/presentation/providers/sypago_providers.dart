import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/sypago_repository.dart';

final sypagoRepositoryProvider = Provider<SypagoRepository>(
  (_) => SypagoRepository(),
);

// ============ Estado del flujo SyPago ============

enum SypagoPaso {
  datosCliente, // formulario inicial
  ingresarOtp, // ingresar código SMS
  esperandoWebhook, // polling
  aprobado, // ACCP
  rechazado, // RJCT
  timeout, // no llegó el webhook
}

class SypagoState {
  final SypagoPaso paso;
  final int? pedidoId;
  final String? transactionId;
  final String? error;
  final bool loading;

  const SypagoState({
    this.paso = SypagoPaso.datosCliente,
    this.pedidoId,
    this.transactionId,
    this.error,
    this.loading = false,
  });

  SypagoState copyWith({
    SypagoPaso? paso,
    int? pedidoId,
    String? transactionId,
    String? error,
    bool? loading,
    bool clearError = false,
  }) => SypagoState(
    paso: paso ?? this.paso,
    pedidoId: pedidoId ?? this.pedidoId,
    transactionId: transactionId ?? this.transactionId,
    error: clearError ? null : (error ?? this.error),
    loading: loading ?? this.loading,
  );
}

class SypagoNotifier extends StateNotifier<SypagoState> {
  final SypagoRepository _repo;
  SypagoNotifier(this._repo) : super(const SypagoState());

  /// Paso 1: solicitar OTP (llamado desde el formulario)
  Future<bool> solicitarOtp({
    required int pedidoId,
    required String documentoTipo,
    required String documentoNumero,
    required String bancoCodigo,
    required String cuentaTipo,
    required String cuentaNumero,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      await _repo.solicitarOtp(
        pedidoId: pedidoId,
        documentoTipo: documentoTipo,
        documentoNumero: documentoNumero,
        bancoCodigo: bancoCodigo,
        cuentaTipo: cuentaTipo,
        cuentaNumero: cuentaNumero,
      );
      state = state.copyWith(
        paso: SypagoPaso.ingresarOtp,
        pedidoId: pedidoId,
        loading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
      return false;
    }
  }

  /// Paso 2: cobrar con OTP
  Future<bool> cobrar({
    required String otp,
    required String clienteNombre,
  }) async {
    if (state.pedidoId == null) return false;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final txId = await _repo.cobrar(
        pedidoId: state.pedidoId!,
        otp: otp,
        clienteNombre: clienteNombre,
      );
      state = state.copyWith(
        paso: SypagoPaso.esperandoWebhook,
        transactionId: txId,
        loading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
      return false;
    }
  }

  /// Actualizar estado final (llamado desde el polling)
  void setPaso(SypagoPaso paso) {
    state = state.copyWith(paso: paso);
  }

  void reset() {
    state = const SypagoState();
  }
}

final sypagoProvider = StateNotifierProvider<SypagoNotifier, SypagoState>(
  (ref) => SypagoNotifier(ref.read(sypagoRepositoryProvider)),
);
