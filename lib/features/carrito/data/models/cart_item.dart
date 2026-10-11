import 'package:hive/hive.dart';

part 'cart_item.g.dart';

@HiveType(typeId: 0)
class CartItem extends HiveObject {
  @HiveField(0)
  final int productoId;

  @HiveField(1)
  final String nombre;

  @HiveField(2)
  final String slug;

  @HiveField(3)
  final double precio;

  @HiveField(4)
  final double precioUnitario;

  @HiveField(5)
  final double? precioEspecial;

  @HiveField(6)
  final bool aplicaPrecioEspecial;

  @HiveField(7)
  int cantidad;

  @HiveField(8)
  final String? imagen;

  @HiveField(9)
  final String? presentacion;

  CartItem({
    required this.productoId,
    required this.nombre,
    required this.slug,
    required this.precio,
    required this.precioUnitario,
    this.precioEspecial,
    required this.aplicaPrecioEspecial,
    required this.cantidad,
    this.imagen,
    this.presentacion,
  });

  double get subtotal => precio * cantidad;

  /// Formato que espera POST /carrito/calculator y POST /checkout
  Map<String, dynamic> toApiJson() => {
    'producto_id': productoId,
    'cantidad': cantidad,
  };
}
