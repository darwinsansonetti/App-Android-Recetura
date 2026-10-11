import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/cart_item.dart';
import '../../data/repositories/cart_repository.dart';

final cartRepositoryProvider = Provider<CartRepository>(
  (_) => CartRepository(),
);

class CartState {
  final List<CartItem> items;
  final bool loading;

  const CartState({this.items = const [], this.loading = false});

  int get totalItems => items.fold(0, (sum, item) => sum + item.cantidad);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);

  /// IVA aproximado (16%) — el backend recalcula el exacto
  double get iva => subtotal * 0.16;

  double get total => subtotal + iva;

  bool get isEmpty => items.isEmpty;

  CartState copyWith({List<CartItem>? items, bool? loading}) =>
      CartState(items: items ?? this.items, loading: loading ?? this.loading);
}

class CartNotifier extends StateNotifier<CartState> {
  final CartRepository _repo;
  final Ref _ref;
  int? _userId;

  CartNotifier(this._repo, this._ref) : super(const CartState()) {
    // Escuchamos el authProvider para cambiar de carrito cuando cambia el usuario
    _ref.listen<int?>(authProvider.select((s) => s.user?.id), (_, nuevoId) {
      _onUserChanged(nuevoId);
    }, fireImmediately: true);
  }

  void _onUserChanged(int? newUserId) {
    if (newUserId == _userId) return;
    _userId = newUserId;
    if (newUserId == null) {
      // Logout → carrito vacío en memoria
      state = const CartState();
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    if (_userId == null) return;
    state = state.copyWith(loading: true);
    final items = await _repo.getItems(_userId!);
    state = CartState(items: items);
  }

  Future<void> add(CartItem item) async {
    if (_userId == null) return;
    await _repo.add(_userId!, item);
    await _load();
  }

  Future<void> updateQty(int productoId, int cantidad) async {
    if (_userId == null) return;
    await _repo.updateQty(_userId!, productoId, cantidad);
    await _load();
  }

  Future<void> remove(int productoId) async {
    if (_userId == null) return;
    await _repo.remove(_userId!, productoId);
    await _load();
  }

  Future<void> clear() async {
    if (_userId == null) return;
    await _repo.clear(_userId!);
    await _load();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(ref.read(cartRepositoryProvider), ref),
);
