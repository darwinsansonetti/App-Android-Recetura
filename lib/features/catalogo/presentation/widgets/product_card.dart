import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../carrito/presentation/providers/cart_provider.dart';
import '../../../carrito/presentation/utils/producto_to_cart.dart';
import '../../data/models/producto.dart';

class ProductCard extends ConsumerWidget {
  final Producto producto;

  const ProductCard({super.key, required this.producto});

  Future<void> _agregar(BuildContext context, WidgetRef ref) async {
    await ref.read(cartProvider.notifier).add(productToCartItem(producto));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${producto.nombre} agregado'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.lgAll,
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: () => context.push('/catalogo/producto/${producto.slug}'),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagen flexible (se adapta al alto disponible)
              Flexible(
                flex: 6,
                child: ClipRRect(
                  borderRadius: AppRadius.mdAll,
                  child: _ImagenProducto(url: producto.imagen),
                ),
              ),
              const SizedBox(height: 6),

              // Nombre (máx 2 líneas)
              Flexible(
                flex: 2,
                child: Text(
                  producto.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.15,
                  ),
                ),
              ),
              const SizedBox(height: 2),

              // Precio + botón
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (producto.aplicaPrecioEspecial &&
                            producto.precioEspecial != null)
                          Text(
                            '\$${producto.precioUnitario.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textTertiary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          '\$${producto.precio.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: producto.aplicaPrecioEspecial
                                ? AppColors.success
                                : AppColors.secondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _BotonAgregar(
                    onPressed: producto.tieneStock
                        ? () => _agregar(context, ref)
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagenProducto extends StatelessWidget {
  final String? url;
  const _ImagenProducto({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        color: AppColors.background,
        child: const Center(
          child: Icon(
            Icons.medication_outlined,
            size: 40,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.contain,
      width: double.infinity,
      placeholder: (_, _) => Container(color: AppColors.background),
      errorWidget: (_, _, _) => Container(
        color: AppColors.background,
        child: const Center(
          child: Icon(
            Icons.medication_outlined,
            size: 40,
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

class _BotonAgregar extends StatelessWidget {
  final VoidCallback? onPressed;
  const _BotonAgregar({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onPressed == null
          ? AppColors.borderLight
          : AppColors.secondary.withValues(alpha: 0.12),
      borderRadius: AppRadius.smAll,
      child: InkWell(
        borderRadius: AppRadius.smAll,
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.add_shopping_cart,
            size: 16,
            color: onPressed == null
                ? AppColors.textTertiary
                : AppColors.secondary,
          ),
        ),
      ),
    );
  }
}
