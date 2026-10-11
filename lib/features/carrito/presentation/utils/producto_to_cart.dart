import '../../data/models/cart_item.dart';
import '../../../catalogo/data/models/producto.dart';

/// Convierte un Producto de la API a un CartItem local
CartItem productToCartItem(Producto producto, {int cantidad = 1}) {
  return CartItem(
    productoId: producto.id,
    nombre: producto.nombre,
    slug: producto.slug,
    precio: producto.precio,
    precioUnitario: producto.precioUnitario,
    precioEspecial: producto.precioEspecial,
    aplicaPrecioEspecial: producto.aplicaPrecioEspecial,
    cantidad: cantidad,
    imagen: producto.imagen,
    presentacion: producto.presentacion,
  );
}
