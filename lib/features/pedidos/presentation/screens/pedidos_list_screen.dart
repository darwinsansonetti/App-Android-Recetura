import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/empty_view.dart';
import '../providers/pedidos_providers.dart';
import '../widgets/pedido_card.dart';

class PedidosListScreen extends ConsumerStatefulWidget {
  final bool showAppBar;
  const PedidosListScreen({super.key, this.showAppBar = true});

  @override
  ConsumerState<PedidosListScreen> createState() => _PedidosListScreenState();
}

class _PedidosListScreenState extends ConsumerState<PedidosListScreen> {
  final _scrollCtrl = ScrollController();

  /// Filtros disponibles. `null` = todos
  static const _filtros = <String, String>{
    'todos': 'Todos',
    'pendiente': 'Pendientes',
    'procesando': 'En proceso',
    'completado': 'Completados',
    'entregado': 'Entregados',
    'rechazado': 'Rechazados',
  };

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
    if (pos.pixels >= pos.maxScrollExtent - 400) {
      ref.read(pedidosPaginadosProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pedidosPaginadosProvider);
    final filtroActual = ref.watch(pedidosFiltroProvider);
    final hPad = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.showAppBar
          ? AppBar(title: const Text('Mis Pedidos'))
          : null,
      body: Column(
        children: [
          // ===== Filtros por estado =====
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: hPad,
                vertical: AppSpacing.sm,
              ),
              itemCount: _filtros.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (_, i) {
                final key = _filtros.keys.elementAt(i);
                final label = _filtros[key]!;
                final selected = filtroActual == key;
                return _FiltroChip(
                  label: label,
                  selected: selected,
                  onTap: () {
                    ref.read(pedidosFiltroProvider.notifier).state = key;
                  },
                );
              },
            ),
          ),

          // ===== Contenido =====
          Expanded(
            child: state.loading && state.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : state.error != null && state.items.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(hPad),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(state.error!, textAlign: TextAlign.center),
                          const SizedBox(height: AppSpacing.md),
                          TextButton.icon(
                            onPressed: () => ref
                                .read(pedidosPaginadosProvider.notifier)
                                .refresh(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  )
                : state.items.isEmpty
                ? const EmptyView(
                    icon: Icons.receipt_long_outlined,
                    title: 'Sin pedidos',
                    subtitle: 'Aquí verás el historial de tus compras',
                  )
                : RefreshIndicator(
                    onRefresh: () async =>
                        ref.read(pedidosPaginadosProvider.notifier).refresh(),
                    child: ListView.separated(
                      controller: _scrollCtrl,
                      padding: EdgeInsets.fromLTRB(
                        hPad,
                        AppSpacing.md,
                        hPad,
                        AppSpacing.xxl,
                      ),
                      itemCount: state.items.length + 1,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (_, i) {
                        if (i == state.items.length) {
                          return _FooterPaginacion(
                            loadingMore: state.loadingMore,
                            hasMore: state.hasMore,
                          );
                        }
                        return PedidoCard(pedido: state.items[i]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FiltroChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.secondary : AppColors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.secondary : AppColors.borderLight,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
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
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }
    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(
          child: Text(
            'No hay más pedidos',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
