class CarritoItemCalculado {
  final int productoId;
  final String nombre;
  final int cantidad;
  final double precioUnitario;
  final double? precioEspecial;
  final double precioAplicado;
  final double subtotal;
  final String? imagen;
  final int stockDisponible;

  const CarritoItemCalculado({
    required this.productoId,
    required this.nombre,
    required this.cantidad,
    required this.precioUnitario,
    this.precioEspecial,
    required this.precioAplicado,
    required this.subtotal,
    this.imagen,
    required this.stockDisponible,
  });

  factory CarritoItemCalculado.fromJson(Map<String, dynamic> j) =>
      CarritoItemCalculado(
        productoId: (j['producto_id'] ?? 0) as int,
        nombre: (j['nombre'] ?? '') as String,
        cantidad: (j['cantidad'] ?? 0) as int,
        precioUnitario: ((j['precio_unitario'] ?? 0) as num).toDouble(),
        precioEspecial: j['precio_especial'] != null
            ? (j['precio_especial'] as num).toDouble()
            : null,
        precioAplicado: ((j['precio_aplicado'] ?? 0) as num).toDouble(),
        subtotal: ((j['subtotal'] ?? 0) as num).toDouble(),
        imagen: j['imagen'] as String?,
        stockDisponible: (j['stock_disponible'] ?? 0) as int,
      );
}

class CarritoCalculado {
  final List<CarritoItemCalculado> items;
  final double subtotal;
  final double iva;
  final double total;

  const CarritoCalculado({
    required this.items,
    required this.subtotal,
    required this.iva,
    required this.total,
  });

  factory CarritoCalculado.fromJson(Map<String, dynamic> j) => CarritoCalculado(
    items: ((j['items'] ?? []) as List)
        .whereType<Map>()
        .map((e) => CarritoItemCalculado.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    subtotal: ((j['subtotal'] ?? 0) as num).toDouble(),
    iva: ((j['iva'] ?? 0) as num).toDouble(),
    total: ((j['total'] ?? 0) as num).toDouble(),
  );
}
