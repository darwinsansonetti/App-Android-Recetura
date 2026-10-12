import '../../../catalogo/data/models/pagination_meta.dart';
import 'pedido.dart';

class PaginatedPedidos {
  final List<Pedido> data;
  final PaginationMeta meta;

  const PaginatedPedidos({required this.data, required this.meta});
}
