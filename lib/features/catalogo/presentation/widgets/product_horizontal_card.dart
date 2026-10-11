import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/models/producto.dart';

class ProductHorizontalCard extends StatelessWidget {
  final Producto producto;
  final double width;

  const ProductHorizontalCard({
    super.key,
    required this.producto,
    this.width = 180,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        child: InkWell(
          borderRadius: AppRadius.lgAll,
          onTap: () => context.push('/catalogo/producto/${producto.slug}'),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagen cuadrada
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: AppRadius.mdAll,
                    child: _buildImagen(),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Nombre
                Text(
                  producto.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),

                // Precio
                Row(
                  children: [
                    Text(
                      '\$${producto.precio.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: producto.aplicaPrecioEspecial
                            ? AppColors.success
                            : AppColors.secondary,
                      ),
                    ),
                    if (producto.aplicaPrecioEspecial &&
                        producto.precioEspecial != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '\$${producto.precioUnitario.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagen() {
    if (producto.imagen == null || producto.imagen!.isEmpty) {
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
      imageUrl: producto.imagen!,
      fit: BoxFit.contain,
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
