import 'pedido_producto.dart';

class PedidoDetalleItem {
  final int id;
  final int productoId;
  final int cantidad;
  final double precioUnitario;
  final double? precioEspecial;
  final double precioAplicado;
  final double subtotal;
  final double total;
  final PedidoProducto producto;

  const PedidoDetalleItem({
    required this.id,
    required this.productoId,
    required this.cantidad,
    required this.precioUnitario,
    this.precioEspecial,
    required this.precioAplicado,
    required this.subtotal,
    required this.total,
    required this.producto,
  });

  factory PedidoDetalleItem.fromJson(Map<String, dynamic> j) =>
      PedidoDetalleItem(
        id: (j['id'] ?? 0) as int,
        productoId: (j['producto_id'] ?? 0) as int,
        cantidad: (j['cantidad'] ?? 0) as int,
        precioUnitario: ((j['precio_unitario'] ?? 0) as num).toDouble(),
        precioEspecial: j['precio_especial'] != null
            ? (j['precio_especial'] as num).toDouble()
            : null,
        precioAplicado: ((j['precio_aplicado'] ?? 0) as num).toDouble(),
        subtotal: ((j['subtotal'] ?? 0) as num).toDouble(),
        total: ((j['total'] ?? 0) as num).toDouble(),
        producto: PedidoProducto.fromJson(
          Map<String, dynamic>.from(j['producto'] as Map),
        ),
      );
}
