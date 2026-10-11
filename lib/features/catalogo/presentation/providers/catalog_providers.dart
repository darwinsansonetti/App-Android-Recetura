import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/categoria.dart';
import '../../data/models/producto.dart';
import '../../data/models/tasa.dart';
import '../../data/repositories/catalog_repository.dart';
import 'productos_paginados_notifier.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (_) => CatalogRepository(),
);

// ============ CATEGORÍAS ============

final categoriasProvider = FutureProvider.autoDispose<List<Categoria>>((ref) {
  return ref.read(catalogRepositoryProvider).getCategorias();
});

final categoriaDetalleProvider = FutureProvider.autoDispose
    .family<Categoria, int>((ref, id) {
      return ref.read(catalogRepositoryProvider).getCategoria(id);
    });

// ============ PRODUCTOS DESTACADOS ============

final productosDestacadosProvider = FutureProvider.autoDispose<List<Producto>>((
  ref,
) {
  return ref.read(catalogRepositoryProvider).getDestacados();
});

// ============ FILTROS GLOBALES ============

/// Filtros que alimentan la lista principal (home y listado)
/// Nota: usamos un StateNotifier en lugar de StateProvider porque ahora
/// ProductosFiltros implementa == y hashCode (evita rebuilds innecesarios).
class FiltrosNotifier extends StateNotifier<ProductosFiltros> {
  FiltrosNotifier() : super(const ProductosFiltros());

  void set(ProductosFiltros nuevos) {
    if (state != nuevos) state = nuevos;
  }

  void update(ProductosFiltros Function(ProductosFiltros) f) {
    final nuevos = f(state);
    if (state != nuevos) state = nuevos;
  }

  void clearCategoria() => update((f) => f.copyWith(clearCategoria: true));
  void clearOrden() => update((f) => f.copyWith(clearOrden: true));
  void reset() => state = const ProductosFiltros();
}

final productosFiltrosProvider =
    StateNotifierProvider<FiltrosNotifier, ProductosFiltros>(
      (ref) => FiltrosNotifier(),
    );

// ============ PRODUCTOS PAGINADOS (home y listado) ============

final productosPaginadosProvider =
    StateNotifierProvider.autoDispose<
      ProductosPaginadosNotifier,
      ProductosState
    >((ref) {
      final filtros = ref.watch(productosFiltrosProvider);
      final repo = ref.read(catalogRepositoryProvider);
      return ProductosPaginadosNotifier(repo, filtros);
    });

// ============ PRODUCTO DETALLE ============

final productoDetalleProvider = FutureProvider.autoDispose
    .family<Producto, String>((ref, idOrSlug) {
      return ref.read(catalogRepositoryProvider).getProducto(idOrSlug);
    });

// ============ TASA ACTUAL ============

final tasaActualProvider = FutureProvider.autoDispose<Tasa>((ref) {
  return ref.read(catalogRepositoryProvider).getTasaActual();
});
