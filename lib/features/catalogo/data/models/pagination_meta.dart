import 'producto.dart';

class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> j) => PaginationMeta(
    currentPage: (j['current_page'] ?? 1) as int,
    lastPage: (j['last_page'] ?? 1) as int,
    perPage: (j['per_page'] ?? 15) as int,
    total: (j['total'] ?? 0) as int,
  );

  bool get hasMore => currentPage < lastPage;

  static const empty = PaginationMeta(
    currentPage: 1,
    lastPage: 1,
    perPage: 15,
    total: 0,
  );
}

class PaginatedProductos {
  final List<Producto> data;
  final PaginationMeta meta;

  const PaginatedProductos({required this.data, required this.meta});
}
