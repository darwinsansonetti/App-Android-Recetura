class PedidoProducto {
  final int id;
  final String nombre;
  final String slug;
  final String? presentacion;
  final List<String> imagenes;
  final String? imagenPrincipal;

  const PedidoProducto({
    required this.id,
    required this.nombre,
    required this.slug,
    this.presentacion,
    required this.imagenes,
    this.imagenPrincipal,
  });

  String? get imagen =>
      imagenPrincipal ?? (imagenes.isNotEmpty ? imagenes.first : null);

  factory PedidoProducto.fromJson(Map<String, dynamic> j) => PedidoProducto(
    id: (j['id'] ?? 0) as int,
    nombre: (j['nombre'] ?? '') as String,
    slug: (j['slug'] ?? '') as String,
    presentacion: j['presentacion'] as String?,
    imagenes: ((j['imagenes'] ?? []) as List).map((e) => e.toString()).toList(),
    imagenPrincipal: j['imagen_principal'] as String?,
  );
}
