import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Este widget actúa como dispatcher: según el rol del usuario,
/// redirige a la vista correspondiente.
///
/// - Aliado → /aliado
/// - Consumidor / Distribuidor / Negocio / Profesional → /catalogo
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_redirect);
  }

  void _redirect() {
    if (!mounted) return;
    final user = ref.read(authProvider).user;

    if (user == null) {
      context.go('/login');
      return;
    }

    switch (user.roleSlug) {
      case 'aliado':
        context.go('/aliado');
        break;
      case 'distribuidor':
      case 'negocio':
      case 'profesional':
      case 'consumidor':
      default:
        context.go('/catalogo');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
