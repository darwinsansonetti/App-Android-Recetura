import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'aliado_dashboard_screen.dart';
import 'distribuidores_list_screen.dart';

class AliadoShellScreen extends ConsumerStatefulWidget {
  const AliadoShellScreen({super.key});

  @override
  ConsumerState<AliadoShellScreen> createState() => _AliadoShellScreenState();
}

class _AliadoShellScreenState extends ConsumerState<AliadoShellScreen> {
  int _index = 0;

  static const _titles = ['Panel', 'Mis Distribuidores'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: const [AliadoDashboardScreen(), DistribuidoresListScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.secondary.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.secondary),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: AppColors.secondary),
            label: 'Distribuidores',
          ),
        ],
      ),
    );
  }
}
