import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/empty_view.dart';
import '../providers/catalog_providers.dart';
import '../widgets/product_card.dart';

class ProductosListScreen extends ConsumerStatefulWidget {
  final int? categoriaId;
  final String? titulo;

  const ProductosListScreen({super.key, this.categoriaId, this.titulo});

  @override
  ConsumerState<ProductosListScreen> createState() =>
      _ProductosListScreenState();
}

class _ProductosListScreenState extends ConsumerState<ProductosListScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    Future.microtask(() {
      ref.read(productosFiltrosProvider.notifier).update((f) {
        return widget.categoriaId != null
            ? f.copyWith(categoriaId: widget.categoriaId, buscar: '')
            : f.copyWith(clearCategoria: true, buscar: '');
      });
    });
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position;
    if (pos.pixels >= pos.maxScrollExtent - 400) {
      ref.read(productosPaginadosProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productosPaginadosProvider);
    final filtros = ref.watch(productosFiltrosProvider);
    final hPad = Responsive.horizontalPadding(context);
    final columns = Responsive.gridColumns(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.titulo ?? 'Productos'),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.sort),
            tooltip: 'Ordenar',
            onSelected: (v) {
              ref.read(productosFiltrosProvider.notifier).update((f) {
                return v == null
                    ? f.copyWith(clearOrden: true)
                    : f.copyWith(orden: v);
              });
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: null, child: Text('Recientes')),
              PopupMenuItem(value: 'precio_asc', child: Text('Precio: menor')),
              PopupMenuItem(value: 'precio_desc', child: Text('Precio: mayor')),
              PopupMenuItem(value: 'nombre_asc', child: Text('Nombre A-Z')),
              PopupMenuItem(value: 'nombre_desc', child: Text('Nombre Z-A')),
            ],
          ),
        ],
      ),
      body: state.loading && state.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.error != null && state.items.isEmpty
          ? Center(child: Text(state.error!))
          : state.items.isEmpty
          ? const EmptyView(
              icon: Icons.inventory_2_outlined,
              title: 'Sin productos',
              subtitle: 'Prueba con otra categoría',
            )
          : Column(
              children: [
                // Contador + chip de orden
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    hPad,
                    AppSpacing.md,
                    hPad,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${state.meta.total} productos',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (filtros.orden != null) ...[
                        const Spacer(),
                        Chip(
                          label: Text(_labelOrden(filtros.orden!)),
                          onDeleted: () {
                            ref
                                .read(productosFiltrosProvider.notifier)
                                .clearOrden();
                          },
                        ),
                      ],
                    ],
                  ),
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async =>
                        ref.read(productosPaginadosProvider.notifier).refresh(),
                    child: GridView.builder(
                      controller: _scrollCtrl,
                      padding: EdgeInsets.fromLTRB(
                        hPad,
                        0,
                        hPad,
                        AppSpacing.xxl,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.62,
                      ),
                      itemCount: state.items.length,
                      itemBuilder: (_, i) =>
                          ProductCard(producto: state.items[i]),
                    ),
                  ),
                ),

                // Loading more footer
                if (state.loadingMore)
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
              ],
            ),
    );
  }

  String _labelOrden(String orden) {
    switch (orden) {
      case 'precio_asc':
        return 'Precio: menor';
      case 'precio_desc':
        return 'Precio: mayor';
      case 'nombre_asc':
        return 'Nombre A-Z';
      case 'nombre_desc':
        return 'Nombre Z-A';
      default:
        return 'Recientes';
    }
  }
}
