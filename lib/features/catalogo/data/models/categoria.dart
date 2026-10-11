class Categoria {
  final int id;
  final String nombre;
  final String? imagen;
  final bool activo;
  final String? estadoColor;
  final List<String> atributosEspecificos;
  final int productosCount;

  const Categoria({
    required this.id,
    required this.nombre,
    this.imagen,
    required this.activo,
    this.estadoColor,
    required this.atributosEspecificos,
    required this.productosCount,
  });

  factory Categoria.fromJson(Map<String, dynamic> j) => Categoria(
    id: (j['id'] ?? 0) as int,
    nombre: (j['nombre'] ?? '') as String,
    imagen: j['imagen'] as String?,
    activo: (j['activo'] ?? true) as bool,
    estadoColor: j['estado_color'] as String?,
    atributosEspecificos: ((j['atributos_especificos'] ?? []) as List)
        .map((e) => e.toString())
        .toList(),
    productosCount: (j['productos_count'] ?? 0) as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'imagen': imagen,
    'activo': activo,
    'estado_color': estadoColor,
    'atributos_especificos': atributosEspecificos,
    'productos_count': productosCount,
  };
}
