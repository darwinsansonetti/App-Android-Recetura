import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/async_value_widget.dart';
import '../../data/models/producto.dart';
import '../providers/catalog_providers.dart';
import '../widgets/precio_widget.dart';
import '../widgets/stock_badge.dart';
import '../../../carrito/presentation/providers/cart_provider.dart';
import '../../../carrito/presentation/utils/producto_to_cart.dart';

class ProductoDetalleScreen extends ConsumerStatefulWidget {
  final String idOrSlug;
  const ProductoDetalleScreen({super.key, required this.idOrSlug});

  @override
  ConsumerState<ProductoDetalleScreen> createState() =>
      _ProductoDetalleScreenState();
}

class _ProductoDetalleScreenState extends ConsumerState<ProductoDetalleScreen> {
  int _cantidad = 1;
  int _imagenActual = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(productoDetalleProvider(widget.idOrSlug));
    final hPad = Responsive.horizontalPadding(context);
    final isWide = !Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detalle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Compartir próximamente')),
              );
            },
          ),
        ],
      ),
      body: AsyncValueWidget<Producto>(
        value: async,
        data: (producto) => ListView(
          padding: EdgeInsets.all(hPad),
          children: [
            if (isWide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _GaleriaImagenes(
                      producto: producto,
                      controller: _pageController,
                      imagenActual: _imagenActual,
                      onChange: (i) => setState(() => _imagenActual = i),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(child: _InfoProducto(producto: producto)),
                ],
              )
            else ...[
              _GaleriaImagenes(
                producto: producto,
                controller: _pageController,
                imagenActual: _imagenActual,
                onChange: (i) => setState(() => _imagenActual = i),
              ),
              const SizedBox(height: AppSpacing.lg),
              _InfoProducto(producto: producto),
            ],
            const SizedBox(height: AppSpacing.lg),

            // ===== Selector cantidad + botón =====
            _CantidadYAgregar(
              producto: producto,
              cantidad: _cantidad,
              onChange: (v) => setState(() => _cantidad = v),
              onAgregar: () async {
                await ref
                    .read(cartProvider.notifier)
                    .add(productToCartItem(producto, cantidad: _cantidad));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text('${producto.nombre} x$_cantidad agregado'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _GaleriaImagenes extends StatelessWidget {
  final Producto producto;
  final PageController controller;
  final int imagenActual;
  final ValueChanged<int> onChange;

  const _GaleriaImagenes({
    required this.producto,
    required this.controller,
    required this.imagenActual,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final imagenes = producto.imagenes.isNotEmpty
        ? producto.imagenes
        : (producto.imagen != null ? [producto.imagen!] : <String>[]);

    if (imagenes.isEmpty) {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: AppColors.surface,
          child: const Center(
            child: Icon(
              Icons.medication_outlined,
              size: 80,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.lgAll,
            ),
            child: PageView.builder(
              controller: controller,
              onPageChanged: onChange,
              itemCount: imagenes.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: CachedNetworkImage(
                  imageUrl: imagenes[i],
                  fit: BoxFit.contain,
                  placeholder: (_, _) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (imagenes.length > 1) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              imagenes.length,
              (i) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == imagenActual
                      ? AppColors.secondary
                      : AppColors.borderLight,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _InfoProducto extends StatelessWidget {
  final Producto producto;
  const _InfoProducto({required this.producto});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Categoría
        if (producto.categoria != null)
          Text(
            producto.categoria!.nombre.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: AppColors.secondary,
            ),
          ),
        const SizedBox(height: 4),

        // Nombre
        Text(
          producto.nombre,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Precio
        PrecioWidget(producto: producto, fontSize: 26),
        const SizedBox(height: AppSpacing.md),

        // Stock
        StockBadge(producto: producto),
        const SizedBox(height: AppSpacing.lg),

        // Descripción
        if (producto.descripcion != null &&
            producto.descripcion!.isNotEmpty) ...[
          Text(
            'Descripción',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            producto.descripcion!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Info técnica
        _InfoRow('Presentación', producto.presentacion),
        _InfoRow('Composición', producto.composicion),
        _InfoRow('SKU', producto.codigoBarra),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CantidadYAgregar extends StatelessWidget {
  final Producto producto;
  final int cantidad;
  final ValueChanged<int> onChange;
  final VoidCallback onAgregar;

  const _CantidadYAgregar({
    required this.producto,
    required this.cantidad,
    required this.onChange,
    required this.onAgregar,
  });

  @override
  Widget build(BuildContext context) {
    if (!producto.tieneStock) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: AppRadius.mdAll,
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.error, size: 20),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Producto sin stock',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    final isWide = !Responsive.isMobile(context);

    final selectorCantidad = _SelectorCantidad(
      cantidad: cantidad,
      max: producto.stock,
      onChange: onChange,
    );

    final botonAgregar = AppButton(
      label: 'Agregar al carrito',
      icon: Icons.shopping_cart_outlined,
      onPressed: onAgregar,
    );

    if (isWide) {
      // Tablet/desktop: fila horizontal
      return Row(
        children: [
          selectorCantidad,
          const SizedBox(width: AppSpacing.md),
          Expanded(child: botonAgregar),
        ],
      );
    }

    // Mobile: apilado vertical
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        selectorCantidad,
        const SizedBox(height: AppSpacing.md),
        botonAgregar,
      ],
    );
  }
}

class _SelectorCantidad extends StatelessWidget {
  final int cantidad;
  final int max;
  final ValueChanged<int> onChange;

  const _SelectorCantidad({
    required this.cantidad,
    required this.max,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove, size: 18),
            onPressed: cantidad > 1 ? () => onChange(cantidad - 1) : null,
            visualDensity: VisualDensity.compact,
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$cantidad',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: cantidad < max ? () => onChange(cantidad + 1) : null,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
