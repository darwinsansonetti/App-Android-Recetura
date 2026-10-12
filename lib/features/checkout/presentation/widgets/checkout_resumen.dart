import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/models/carrito_calculado.dart';

class CheckoutResumen extends StatelessWidget {
  final CarritoCalculado calculo;
  final VoidCallback onConfirm;
  final bool loading;
  final String labelBoton;

  const CheckoutResumen({
    super.key,
    required this.calculo,
    required this.onConfirm,
    required this.loading,
    this.labelBoton = 'Confirmar pedido',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Resumen del pedido',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),

          // Items
          ...calculo.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: AppRadius.smAll,
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: _ImagenItem(url: item.imagen),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.nombre,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${item.cantidad} × \$${item.precioAplicado.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${item.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(),
          const SizedBox(height: AppSpacing.sm),

          // Totales
          _linea('Subtotal', calculo.subtotal),
          const SizedBox(height: 4),
          _linea('IVA (16%)', calculo.iva),
          const SizedBox(height: AppSpacing.sm),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          _linea(
            'Total',
            calculo.total,
            bold: true,
            color: AppColors.secondary,
          ),

          const SizedBox(height: AppSpacing.lg),

          AppButton(
            label: labelBoton,
            icon: Icons.check_circle_outline,
            loading: loading,
            onPressed: onConfirm,
          ),
        ],
      ),
    );
  }

  Widget _linea(String label, double valor, {bool bold = false, Color? color}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: bold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          '\$${valor.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: bold ? 18 : 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ImagenItem extends StatelessWidget {
  final String? url;
  const _ImagenItem({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        color: AppColors.background,
        child: const Center(
          child: Icon(
            Icons.medication_outlined,
            size: 22,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.contain,
      placeholder: (_, _) => Container(color: AppColors.background),
      errorWidget: (_, _, _) => Container(
        color: AppColors.background,
        child: const Center(
          child: Icon(
            Icons.medication_outlined,
            size: 22,
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}
