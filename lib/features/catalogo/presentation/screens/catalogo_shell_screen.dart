import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/shell_tab_provider.dart';
import 'catalogo_home_screen.dart';
import 'carrito_screen.dart';
import 'categorias_list_screen.dart';
import '../../../pedidos/presentation/screens/pedidos_list_screen.dart';

class CatalogoShellScreen extends ConsumerWidget {
  const CatalogoShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(shellTabProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          CatalogoHomeScreen(),
          CategoriasListScreen(),
          CarritoScreen(),
          PedidosListScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex > 3 ? 0 : currentIndex,
        onDestinationSelected: (i) {
          if (i == 4) {
            // Perfil: push en lugar de cambiar tab
            context.push('/perfil');
            return;
          }
          ref.read(shellTabProvider.notifier).state = i;
        },
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.secondary.withValues(alpha: 0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.secondary),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category, color: AppColors.secondary),
            label: 'Categorías',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart, color: AppColors.secondary),
            label: 'Carrito',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: AppColors.secondary),
            label: 'Pedidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.secondary),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
