import '../../../../core/network/dio_client.dart';
import '../../../catalogo/data/models/pagination_meta.dart';
import '../models/paginated_pedidos.dart';
import '../models/pedido.dart';

class PedidosRepository {
  final _dio = DioClient.instance.dio;

  /// GET /pedidos
  Future<PaginatedPedidos> getPedidos({
    String? estado,
    int perPage = 15,
    int page = 1,
  }) async {
    final r = await _dio.get(
      '/pedidos',
      queryParameters: {
        if (estado != null && estado.isNotEmpty) 'estado': estado,
        'per_page': perPage,
        'page': page,
      },
    );

    final data = DioClient.unwrap(r);
    if (data is! Map) {
      throw Exception('Formato inesperado en /pedidos');
    }

    final list = (data['data'] ?? []) as List;
    final meta = (data['meta'] ?? {}) as Map<String, dynamic>;

    return PaginatedPedidos(
      data: list
          .whereType<Map>()
          .map((e) => Pedido.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      meta: PaginationMeta.fromJson(meta),
    );
  }

  /// GET /pedidos/{id}
  Future<Pedido> getPedido(int id) async {
    final r = await _dio.get('/pedidos/$id');
    final data = DioClient.unwrap(r);
    if (data is! Map) {
      throw Exception('Formato inesperado en /pedidos/$id');
    }
    return Pedido.fromJson(Map<String, dynamic>.from(data));
  }
}
