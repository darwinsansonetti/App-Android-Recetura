import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../carrito/presentation/providers/cart_provider.dart';
import '../../data/models/carrito_calculado.dart';
import '../../data/repositories/checkout_repository.dart';
import '../../data/models/cliente_destino.dart';

final checkoutRepositoryProvider = Provider<CheckoutRepository>(
  (_) => CheckoutRepository(),
);

/// Carrito calculado por el backend (subtotal + IVA + total reales)
/// Se recalcula cuando cambia el carrito
final carritoCalculadoProvider = FutureProvider.autoDispose<CarritoCalculado>((
  ref,
) async {
  final cartState = ref.watch(cartProvider);
  if (cartState.items.isEmpty) {
    return const CarritoCalculado(items: [], subtotal: 0, iva: 0, total: 0);
  }
  return ref.read(checkoutRepositoryProvider).calcularCarrito(cartState.items);
});

/// Estado del submit del checkout
class CheckoutState {
  final bool loading;
  final String? error;
  const CheckoutState({this.loading = false, this.error});

  CheckoutState copyWith({
    bool? loading,
    String? error,
    bool clearError = false,
  }) => CheckoutState(
    loading: loading ?? this.loading,
    error: clearError ? null : (error ?? this.error),
  );
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final CheckoutRepository _repo;
  CheckoutNotifier(this._repo) : super(const CheckoutState());

  /// Crea un pedido de consumidor/profesional/negocio
  Future<int?> crearPedido({
    required List<dynamic> items,
    required String numeroReferencia,
    required double monto,
    required String fechaPago,
    required String cedulaIdentidad,
    required String bancoOrigen,
    required String bancoDestino,
    required String direccionEnvio,
    String? notas,
    Map<String, dynamic>? clienteDestino,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final ClienteDestino? cd = clienteDestino != null
          ? ClienteDestino.fromJson(clienteDestino)
          : null;

      final pedido = await _repo.crearPedido(
        items: items.cast(),
        numeroReferencia: numeroReferencia,
        monto: monto,
        fechaPago: fechaPago,
        cedulaIdentidad: cedulaIdentidad,
        bancoOrigen: bancoOrigen,
        bancoDestino: bancoDestino,
        direccionEnvio: direccionEnvio,
        notas: notas,
        clienteDestino: cd,
      );
      state = const CheckoutState();
      return pedido.id;
    } catch (e) {
      state = CheckoutState(error: e.toString());
      return null;
    }
  }

  /// Crea un pedido de distribuidor (crédito)
  Future<int?> crearPedidoCredito({
    required List<dynamic> items,
    required String direccionEnvio,
    String? notas,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final pedido = await _repo.crearPedidoCredito(
        items: items.cast(),
        direccionEnvio: direccionEnvio,
        notas: notas,
      );
      state = const CheckoutState();
      return pedido.id;
    } catch (e) {
      state = CheckoutState(error: e.toString());
      return null;
    }
  }
}

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>(
  (ref) => CheckoutNotifier(ref.read(checkoutRepositoryProvider)),
);
