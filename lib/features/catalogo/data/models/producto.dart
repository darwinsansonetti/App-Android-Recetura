import 'categoria.dart';

class Producto {
  final int id;
  final String nombre;
  final String slug;
  final String? descripcion;
  final String? composicion;
  final String? presentacion;
  final String? codigoBarra;

  /// Precio que corresponde según el rol del usuario (ya calculado por el backend)
  final double precio;

  /// Precio base PVP (siempre presente)
  final double precioUnitario;

  /// Precio especial (solo si aplica)
  final double? precioEspecial;

  /// Flag: ¿este producto tiene precio especial para este usuario?
  final bool aplicaPrecioEspecial;

  /// Condición para precio especial (ej: "Mínimo 5 unidades")
  final int? minimoUnidadesEspecial;
  final String? condicionFormateada;

  final int stock;
  final int? stockMinimo;
  final bool tieneStock;
  final String? stockColor;
  final String? stockTexto;

  final bool activo;
  final bool destacado;

  /// Lista de URLs de imágenes
  final List<String> imagenes;
  final String? imagenPrincipal;

  final Categoria? categoria;

  final DateTime? createdAt;

  const Producto({
    required this.id,
    required this.nombre,
    required this.slug,
    this.descripcion,
    this.composicion,
    this.presentacion,
    this.codigoBarra,
    required this.precio,
    required this.precioUnitario,
    this.precioEspecial,
    required this.aplicaPrecioEspecial,
    this.minimoUnidadesEspecial,
    this.condicionFormateada,
    required this.stock,
    this.stockMinimo,
    required this.tieneStock,
    this.stockColor,
    this.stockTexto,
    required this.activo,
    required this.destacado,
    required this.imagenes,
    this.imagenPrincipal,
    this.categoria,
    this.createdAt,
  });

  factory Producto.fromJson(Map<String, dynamic> j) => Producto(
    id: (j['id'] ?? 0) as int,
    nombre: (j['nombre'] ?? '') as String,
    slug: (j['slug'] ?? '') as String,
    descripcion: j['descripcion'] as String?,
    composicion: j['composicion'] as String?,
    presentacion: j['presentacion'] as String?,
    codigoBarra: j['codigo_barra'] as String?,
    precio: ((j['precio'] ?? 0) as num).toDouble(),
    precioUnitario: ((j['precio_unitario'] ?? 0) as num).toDouble(),
    precioEspecial: j['precio_especial'] != null
        ? (j['precio_especial'] as num).toDouble()
        : null,
    aplicaPrecioEspecial: (j['aplica_precio_especial'] ?? false) as bool,
    minimoUnidadesEspecial: j['minimo_unidades_especial'] as int?,
    condicionFormateada: j['condicion_formateada'] as String?,
    stock: (j['stock'] ?? 0) as int,
    stockMinimo: j['stock_minimo'] as int?,
    tieneStock: (j['tiene_stock'] ?? false) as bool,
    stockColor: j['stock_color'] as String?,
    stockTexto: j['stock_texto'] as String?,
    activo: (j['activo'] ?? true) as bool,
    destacado: (j['destacado'] ?? false) as bool,
    imagenes: ((j['imagenes'] ?? []) as List).map((e) => e.toString()).toList(),
    imagenPrincipal: j['imagen_principal'] as String?,
    categoria: j['categoria'] != null
        ? Categoria.fromJson(Map<String, dynamic>.from(j['categoria'] as Map))
        : null,
    createdAt: j['created_at'] != null
        ? DateTime.tryParse(j['created_at'] as String)
        : null,
  );

  /// Imagen a mostrar como principal (con fallback)
  String? get imagen =>
      imagenPrincipal ?? (imagenes.isNotEmpty ? imagenes.first : null);

  /// Color del stock como hex de Material
  int get stockColorValue {
    switch (stockColor) {
      case 'success':
        return 0xFF10B981;
      case 'danger':
        return 0xFFDC2626;
      case 'warning':
        return 0xFFF59E0B;
      case 'info':
        return 0xFF3B82F6;
      default:
        return 0xFF6B7280;
    }
  }
}
