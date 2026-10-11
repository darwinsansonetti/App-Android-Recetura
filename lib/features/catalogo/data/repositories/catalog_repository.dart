import '../../../../core/network/dio_client.dart';
import '../models/categoria.dart';
import '../models/pagination_meta.dart';
import '../models/producto.dart';
import '../models/tasa.dart';

class CatalogRepository {
  final _dio = DioClient.instance.dio;

  // =============== CATEGORÍAS ===============

  Future<List<Categoria>> getCategorias() async {
    final r = await _dio.get('/categorias');
    final data = DioClient.unwrap(r);
    if (data is! List) {
      throw Exception('Formato inesperado en /categorias');
    }
    return data
        .whereType<Map>()
        .map((e) => Categoria.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Categoria> getCategoria(int id) async {
    final r = await _dio.get('/categorias/$id');
    final data = DioClient.unwrap(r);
    if (data is! Map) {
      throw Exception('Formato inesperado en /categorias/$id');
    }
    return Categoria.fromJson(Map<String, dynamic>.from(data));
  }

  // =============== PRODUCTOS ===============

  /// GET /productos con filtros
  Future<PaginatedProductos> getProductos({
    int? categoriaId,
    String? buscar,
    bool? destacado,
    bool? conStock,
    double? precioMin,
    double? precioMax,
    String? orden,
    int perPage = 15,
    int page = 1,
  }) async {
    final r = await _dio.get(
      '/productos',
      queryParameters: {
        if (categoriaId != null) 'categoria_id': categoriaId,
        if (buscar != null && buscar.isNotEmpty) 'buscar': buscar,
        if (destacado == true) 'destacado': 1,
        if (conStock == true) 'con_stock': 1,
        if (precioMin != null) 'precio_min': precioMin,
        if (precioMax != null) 'precio_max': precioMax,
        if (orden != null && orden.isNotEmpty) 'orden': orden,
        'per_page': perPage,
        'page': page,
      },
    );

    final data = DioClient.unwrap(r);
    if (data is! Map) {
      throw Exception('Formato inesperado en /productos');
    }

    final list = (data['data'] ?? []) as List;
    final meta = (data['meta'] ?? {}) as Map<String, dynamic>;

    return PaginatedProductos(
      data: list
          .whereType<Map>()
          .map((e) => Producto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      meta: PaginationMeta.fromJson(meta),
    );
  }

  /// GET /productos/destacados
  Future<List<Producto>> getDestacados() async {
    final r = await _dio.get('/productos/destacados');
    final data = DioClient.unwrap(r);

    // Puede venir como List directa o como Map {data: [...]}
    List list;
    if (data is List) {
      list = data;
    } else if (data is Map && data['data'] is List) {
      list = data['data'] as List;
    } else {
      throw Exception('Formato inesperado en /productos/destacados');
    }

    return list
        .whereType<Map>()
        .map((e) => Producto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// GET /productos/{idOrSlug}
  Future<Producto> getProducto(String idOrSlug) async {
    final r = await _dio.get('/productos/$idOrSlug');
    final data = DioClient.unwrap(r);
    if (data is! Map) {
      throw Exception('Formato inesperado en /productos/$idOrSlug');
    }
    return Producto.fromJson(Map<String, dynamic>.from(data));
  }

  // =============== TASA ===============

  Future<Tasa> getTasaActual() async {
    final r = await _dio.get('/tasa-actual');
    final data = DioClient.unwrap(r);
    if (data is! Map) {
      throw Exception('Formato inesperado en /tasa-actual');
    }
    return Tasa.fromJson(Map<String, dynamic>.from(data));
  }
}
