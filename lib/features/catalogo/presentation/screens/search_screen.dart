import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/empty_view.dart';
import '../providers/catalog_providers.dart';
import '../widgets/product_card.dart';
import '../widgets/search_input.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String _query = '';
  bool _inicializado = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    // Resetear filtros al entrar
    Future.microtask(() {
      ref.read(productosFiltrosProvider.notifier)
        ..clearCategoria()
        ..update((f) => f.copyWith(buscar: ''));
      _inicializado = true;
    });
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final pos = _scrollCtrl.position;
    if (pos.pixels >= pos.maxScrollExtent - 400) {
      ref.read(productosPaginadosProvider.notifier).loadMore();
    }
  }

  void _buscar(String q) {
    setState(() => _query = q);
    ref.read(productosFiltrosProvider.notifier).update((f) {
      return f.copyWith(buscar: q, clearCategoria: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productosPaginadosProvider);
    final hPad = Responsive.horizontalPadding(context);
    final columns = Responsive.gridColumns(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: SearchInput(
          controller: _ctrl,
          autofocus: true,
          onChanged: _buscar,
          onSubmitted: () => _buscar(_ctrl.text),
        ),
        titleSpacing: 0,
      ),
      body: !_inicializado || _query.isEmpty
          ? const EmptyView(
              icon: Icons.search,
              title: 'Buscar productos',
              subtitle: 'Escribe el nombre, composición o descripción',
            )
          : state.loading && state.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : state.items.isEmpty
          ? EmptyView(
              icon: Icons.search_off,
              title: 'Sin resultados',
              subtitle: 'No encontramos nada para "$_query"',
            )
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    hPad,
                    AppSpacing.md,
                    hPad,
                    AppSpacing.sm,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${state.meta.total} resultados',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    controller: _scrollCtrl,
                    padding: EdgeInsets.fromLTRB(hPad, 0, hPad, AppSpacing.xxl),
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
}
