import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/async_value_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../carrito/presentation/providers/cart_provider.dart';
import '../../data/models/categoria.dart';
import '../../data/models/producto.dart';
import '../providers/catalog_providers.dart';
import '../widgets/categoria_chip.dart';
import '../widgets/product_card.dart';
import '../widgets/product_horizontal_card.dart';
import '../widgets/search_input.dart';
import '../providers/shell_tab_provider.dart';

class CatalogoHomeScreen extends ConsumerStatefulWidget {
  const CatalogoHomeScreen({super.key});

  @override
  ConsumerState<CatalogoHomeScreen> createState() => _CatalogoHomeScreenState();
}

class _CatalogoHomeScreenState extends ConsumerState<CatalogoHomeScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
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
    // Dispara loadMore cuando faltan 400px para llegar al final
    if (pos.pixels >= pos.maxScrollExtent - 400) {
      ref.read(productosPaginadosProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final hPad = Responsive.horizontalPadding(context);
    final columns = Responsive.gridColumns(context);

    final categoriasAsync = ref.watch(categoriasProvider);
    final destacadosAsync = ref.watch(productosDestacadosProvider);
    final productosState = ref.watch(productosPaginadosProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const AppLogo(height: 32),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final totalItems = ref.watch(cartProvider).totalItems;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    tooltip: 'Carrito',
                    onPressed: () {
                      // Cambiar al tab del carrito (índice 2)
                      ref.read(shellTabProvider.notifier).state = 2;
                    },
                  ),
                  if (totalItems > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$totalItems',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(categoriasProvider);
            ref.invalidate(productosDestacadosProvider);
            await ref.read(productosPaginadosProvider.notifier).refresh();
          },
          child: CustomScrollView(
            controller: _scrollCtrl,
            slivers: [
              // ===== Saludo + Búsqueda =====
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    hPad,
                    AppSpacing.md,
                    hPad,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Hola, ${user?.name ?? ''}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '¿Qué necesitas hoy?',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SearchInput(
                        readOnly: true,
                        onTap: () => context.push('/catalogo/buscar'),
                      ),
                    ],
                  ),
                ),
              ),

              // ===== Categorías =====
              SliverToBoxAdapter(
                child: AsyncValueWidget<List<Categoria>>(
                  value: categoriasAsync,
                  data: (categorias) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        child: Text(
                          'Categorías',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          itemCount: categorias.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: AppSpacing.sm),
                          itemBuilder: (_, i) => CategoriaChip(
                            categoria: categorias[i],
                            onTap: () => context.push(
                              '/catalogo/categoria/${categorias[i].id}',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),

              // ===== Destacados =====
              SliverToBoxAdapter(
                child: AsyncValueWidget<List<Producto>>(
                  value: destacadosAsync,
                  data: (destacados) {
                    if (destacados.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: hPad),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: AppColors.accent,
                                size: 22,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Destacados',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          height: 250,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: hPad),
                            itemCount: destacados.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: AppSpacing.md),
                            itemBuilder: (_, i) =>
                                ProductHorizontalCard(producto: destacados[i]),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    );
                  },
                ),
              ),

              // ===== Título "Todos los productos" =====
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    hPad,
                    AppSpacing.sm,
                    hPad,
                    AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Todos los productos',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.push('/catalogo/productos'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Ver todos'),
                      ),
                    ],
                  ),
                ),
              ),

              // ===== Contenido: Loading / Error / Data =====
              if (productosState.loading && productosState.items.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (productosState.error != null &&
                  productosState.items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text(productosState.error!)),
                )
              else ...[
                // ===== Grid =====
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 0, hPad, AppSpacing.md),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.62,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => ProductCard(producto: productosState.items[i]),
                      childCount: productosState.items.length,
                    ),
                  ),
                ),

                // ===== Loading more / fin de lista =====
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      hPad,
                      AppSpacing.md,
                      hPad,
                      AppSpacing.xxl,
                    ),
                    child: _FooterPaginacion(
                      loadingMore: productosState.loadingMore,
                      hasMore: productosState.hasMore,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterPaginacion extends StatelessWidget {
  final bool loadingMore;
  final bool hasMore;
  const _FooterPaginacion({required this.loadingMore, required this.hasMore});

  @override
  Widget build(BuildContext context) {
    if (loadingMore) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }
    if (!hasMore) {
      return Center(
        child: Text(
          'No hay más productos',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
