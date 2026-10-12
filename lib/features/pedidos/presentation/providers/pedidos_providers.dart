import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/pedido.dart';
import '../../data/repositories/pedidos_repository.dart';

final pedidosRepositoryProvider = Provider<PedidosRepository>(
  (_) => PedidosRepository(),
);

// ============ FILTRO DE ESTADO ============

/// Filtro actual de estado ('todos', 'pendiente', 'procesando', etc.)
final pedidosFiltroProvider = StateProvider<String>((_) => 'todos');

// ============ LISTA PAGINADA ============

class PedidosState {
  final List<Pedido> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool loading;
  final bool loadingMore;
  final String? error;

  const PedidosState({
    this.items = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.loading = false,
    this.loadingMore = false,
    this.error,
  });

  bool get hasMore => currentPage < lastPage;
  bool get isEmpty => items.isEmpty;

  PedidosState copyWith({
    List<Pedido>? items,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? loading,
    bool? loadingMore,
    String? error,
    bool clearError = false,
  }) => PedidosState(
    items: items ?? this.items,
    currentPage: currentPage ?? this.currentPage,
    lastPage: lastPage ?? this.lastPage,
    total: total ?? this.total,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    error: clearError ? null : (error ?? this.error),
  );
}

class PedidosNotifier extends StateNotifier<PedidosState> {
  final PedidosRepository _repo;
  final String filtro;

  PedidosNotifier(this._repo, this.filtro) : super(const PedidosState()) {
    _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final res = await _repo.getPedidos(
        estado: filtro == 'todos' ? null : filtro,
        page: 1,
      );
      state = PedidosState(
        items: res.data,
        currentPage: res.meta.currentPage,
        lastPage: res.meta.lastPage,
        total: res.meta.total,
      );
    } catch (e) {
      state = PedidosState(error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.loadingMore || !state.hasMore) return;
    state = state.copyWith(loadingMore: true, clearError: true);
    try {
      final res = await _repo.getPedidos(
        estado: filtro == 'todos' ? null : filtro,
        page: state.currentPage + 1,
      );
      state = state.copyWith(
        items: [...state.items, ...res.data],
        currentPage: res.meta.currentPage,
        lastPage: res.meta.lastPage,
        total: res.meta.total,
        loadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(loadingMore: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await _loadFirstPage();
  }
}

final pedidosPaginadosProvider =
    StateNotifierProvider.autoDispose<PedidosNotifier, PedidosState>((ref) {
      final filtro = ref.watch(pedidosFiltroProvider);
      final repo = ref.read(pedidosRepositoryProvider);
      return PedidosNotifier(repo, filtro);
    });

// ============ DETALLE ============

final pedidoDetalleProvider = FutureProvider.autoDispose.family<Pedido, int>((
  ref,
  id,
) {
  return ref.read(pedidosRepositoryProvider).getPedido(id);
});

/// Pedido detalle — puede venir desde /pedidos o /aliado/pedidos
final pedidoDetalleVistaProvider = FutureProvider.autoDispose
    .family<Pedido, ({int id, bool esAliado})>((ref, params) {
      final repo = ref.read(pedidosRepositoryProvider);
      return params.esAliado
          ? repo.getPedidoAliado(params.id)
          : repo.getPedido(params.id);
    });
