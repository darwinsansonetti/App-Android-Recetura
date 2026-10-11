import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/async_value_widget.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../data/models/categoria.dart';
import '../providers/catalog_providers.dart';

class CategoriasListScreen extends ConsumerWidget {
  const CategoriasListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(categoriasProvider);
    final hPad = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Categorías')),
      body: AsyncValueWidget<List<Categoria>>(
        value: async,
        data: (categorias) {
          if (categorias.isEmpty) {
            return const EmptyView(
              icon: Icons.category_outlined,
              title: 'Sin categorías',
              subtitle: 'Vuelve más tarde',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(categoriasProvider),
            child: ListView.separated(
              padding: EdgeInsets.all(hPad),
              itemCount: categorias.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) => _CategoriaTile(categoria: categorias[i]),
            ),
          );
        },
      ),
    );
  }
}

class _CategoriaTile extends StatelessWidget {
  final Categoria categoria;
  const _CategoriaTile({required this.categoria});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.lgAll,
      child: InkWell(
        borderRadius: AppRadius.lgAll,
        onTap: () => context.push('/catalogo/categoria/${categoria.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: AppRadius.mdAll,
                child: SizedBox(width: 56, height: 56, child: _buildImagen()),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoria.nombre,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${categoria.productosCount} productos',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagen() {
    if (categoria.imagen == null || categoria.imagen!.isEmpty) {
      return Container(
        color: AppColors.background,
        child: const Center(
          child: Icon(
            Icons.category_outlined,
            color: AppColors.textTertiary,
            size: 24,
          ),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: categoria.imagen!,
      fit: BoxFit.cover,
      placeholder: (_, _) => Container(color: AppColors.background),
      errorWidget: (_, _, _) => Container(
        color: AppColors.background,
        child: const Center(
          child: Icon(
            Icons.category_outlined,
            color: AppColors.textTertiary,
            size: 24,
          ),
        ),
      ),
    );
  }
}
