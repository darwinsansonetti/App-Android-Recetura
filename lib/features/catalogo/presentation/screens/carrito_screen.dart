import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../carrito/data/models/cart_item.dart';
import '../../../carrito/presentation/providers/cart_provider.dart';

class CarritoScreen extends ConsumerWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final hPad = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi Carrito'),
        actions: [
          if (!cart.isEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Vaciar carrito',
              onPressed: () => _confirmarVaciar(context, ref),
            ),
        ],
      ),
      body: cart.isEmpty
          ? const EmptyView(
              icon: Icons.shopping_cart_outlined,
              title: 'Carrito vacío',
              subtitle: 'Agrega productos para comenzar',
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.all(hPad),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (_, i) => _CartItemCard(
                      item: cart.items[i],
                      onUpdateQty: (qty) {
                        ref
                            .read(cartProvider.notifier)
                            .updateQty(cart.items[i].productoId, qty);
                      },
                      onRemove: () {
                        ref
                            .read(cartProvider.notifier)
                            .remove(cart.items[i].productoId);
                      },
                    ),
                  ),
                ),
                _ResumenCarrito(
                  subtotal: cart.subtotal,
                  iva: cart.iva,
                  total: cart.total,
                  onCheckout: () {
                    // TODO Bloque 6 (checkout)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Checkout próximamente')),
                    );
                  },
                ),
              ],
            ),
    );
  }

  Future<void> _confirmarVaciar(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vaciar carrito'),
        content: const Text(
          '¿Estás seguro? Se eliminarán todos los productos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(cartProvider.notifier).clear();
    }
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final ValueChanged<int> onUpdateQty;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onUpdateQty,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadius.mdAll,
            child: SizedBox(width: 72, height: 72, child: _buildImagen()),
          ),
          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.presentacion != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.presentacion!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  '\$${item.precio.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 6),

                Row(
                  children: [
                    _QtyButton(
                      icon: Icons.remove,
                      onTap: item.cantidad > 1
                          ? () => onUpdateQty(item.cantidad - 1)
                          : null,
                    ),
                    Container(
                      width: 36,
                      alignment: Alignment.center,
                      child: Text(
                        '${item.cantidad}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _QtyButton(
                      icon: Icons.add,
                      onTap: () => onUpdateQty(item.cantidad + 1),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      onPressed: onRemove,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagen() {
    if (item.imagen == null || item.imagen!.isEmpty) {
      return Container(
        color: AppColors.background,
        child: const Center(
          child: Icon(Icons.medication_outlined, color: AppColors.textTertiary),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: item.imagen!,
      fit: BoxFit.contain,
      placeholder: (_, _) => Container(color: AppColors.background),
      errorWidget: (_, _, _) => Container(
        color: AppColors.background,
        child: const Center(
          child: Icon(Icons.medication_outlined, color: AppColors.textTertiary),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null ? AppColors.borderLight : AppColors.background,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        borderRadius: AppRadius.smAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 16,
            color: onTap == null
                ? AppColors.textTertiary
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _ResumenCarrito extends StatelessWidget {
  final double subtotal;
  final double iva;
  final double total;
  final VoidCallback onCheckout;

  const _ResumenCarrito({
    required this.subtotal,
    required this.iva,
    required this.total,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);

    return Container(
      padding: EdgeInsets.all(hPad),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          _linea('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 4),
          _linea('IVA (16%)', '\$${iva.toStringAsFixed(2)}'),
          const SizedBox(height: AppSpacing.sm),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          _linea('Total', '\$${total.toStringAsFixed(2)}', bold: true),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Proceder al pago',
            icon: Icons.arrow_forward,
            onPressed: onCheckout,
          ),
        ],
      ),
    );
  }

  Widget _linea(String label, String value, {bool bold = false}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            fontSize: bold ? 16 : 14,
            color: bold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            fontSize: bold ? 18 : 14,
            color: bold ? AppColors.secondary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
