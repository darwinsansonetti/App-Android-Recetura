import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/pagination_meta.dart';
import '../../data/models/producto.dart';
import '../../data/repositories/catalog_repository.dart';

/// Filtros que alimentan la lista de productos
class ProductosFiltros {
  final int? categoriaId;
  final String buscar;
  final String? orden;
  final bool soloConStock;
  final bool soloDestacados;
  final int perPage;

  const ProductosFiltros({
    this.categoriaId,
    this.buscar = '',
    this.orden,
    this.soloConStock = false,
    this.soloDestacados = false,
    this.perPage = 15,
  });

  ProductosFiltros copyWith({
    int? categoriaId,
    String? buscar,
    String? orden,
    bool? soloConStock,
    bool? soloDestacados,
    int? perPage,
    bool clearCategoria = false,
    bool clearOrden = false,
  }) => ProductosFiltros(
    categoriaId: clearCategoria ? null : (categoriaId ?? this.categoriaId),
    buscar: buscar ?? this.buscar,
    orden: clearOrden ? null : (orden ?? this.orden),
    soloConStock: soloConStock ?? this.soloConStock,
    soloDestacados: soloDestacados ?? this.soloDestacados,
    perPage: perPage ?? this.perPage,
  );

  @override
  bool operator ==(Object other) =>
      other is ProductosFiltros &&
      other.categoriaId == categoriaId &&
      other.buscar == buscar &&
      other.orden == orden &&
      other.soloConStock == soloConStock &&
      other.soloDestacados == soloDestacados &&
      other.perPage == perPage;

  @override
  int get hashCode => Object.hash(
    categoriaId,
    buscar,
    orden,
    soloConStock,
    soloDestacados,
    perPage,
  );
}

/// Estado de la lista paginada
class ProductosState {
  final List<Producto> items;
  final PaginationMeta meta;
  final bool loading;
  final bool loadingMore;
  final String? error;

  const ProductosState({
    this.items = const [],
    this.meta = PaginationMeta.empty,
    this.loading = false,
    this.loadingMore = false,
    this.error,
  });

  bool get hasMore => meta.hasMore;
  bool get isEmpty => items.isEmpty;

  ProductosState copyWith({
    List<Producto>? items,
    PaginationMeta? meta,
    bool? loading,
    bool? loadingMore,
    String? error,
    bool clearError = false,
  }) => ProductosState(
    items: items ?? this.items,
    meta: meta ?? this.meta,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    error: clearError ? null : (error ?? this.error),
  );
}

/// Notifier con paginación acumulativa
class ProductosPaginadosNotifier extends StateNotifier<ProductosState> {
  final CatalogRepository _repo;
  final ProductosFiltros filtros;

  ProductosPaginadosNotifier(this._repo, this.filtros)
    : super(const ProductosState()) {
    _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final res = await _repo.getProductos(
        categoriaId: filtros.categoriaId,
        buscar: filtros.buscar.isEmpty ? null : filtros.buscar,
        orden: filtros.orden,
        conStock: filtros.soloConStock ? true : null,
        destacado: filtros.soloDestacados ? true : null,
        perPage: filtros.perPage,
        page: 1,
      );
      state = ProductosState(items: res.data, meta: res.meta);
    } catch (e) {
      state = ProductosState(error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.loadingMore || !state.hasMore) return;
    state = state.copyWith(loadingMore: true, clearError: true);
    try {
      final nextPage = state.meta.currentPage + 1;
      final res = await _repo.getProductos(
        categoriaId: filtros.categoriaId,
        buscar: filtros.buscar.isEmpty ? null : filtros.buscar,
        orden: filtros.orden,
        conStock: filtros.soloConStock ? true : null,
        destacado: filtros.soloDestacados ? true : null,
        perPage: filtros.perPage,
        page: nextPage,
      );
      state = ProductosState(
        items: [...state.items, ...res.data],
        meta: res.meta,
      );
    } catch (e) {
      state = state.copyWith(loadingMore: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await _loadFirstPage();
  }
}
