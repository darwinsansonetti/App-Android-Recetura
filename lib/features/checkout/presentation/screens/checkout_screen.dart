import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../carrito/presentation/providers/cart_provider.dart';
import '../../data/models/carrito_calculado.dart';
import '../providers/checkout_providers.dart';
import '../widgets/perfil_incompleto_view.dart';
import 'checkout_consumidor_form.dart';
import 'checkout_distribuidor_form.dart';
import 'checkout_negocio_form.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final hPad = Responsive.horizontalPadding(context);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Sesión expirada')));
    }

    if (!user.perfilCompleto) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Checkout')),
        body: PerfilIncompletoView(user: user),
      );
    }

    final cartItems = ref.watch(cartProvider).items;
    if (cartItems.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: Text('Tu carrito está vacío')),
      );
    }

    final asyncCalculo = ref.watch(carritoCalculadoProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Checkout')),
      body: SafeArea(
        child: asyncCalculo.when(
          loading: () => const LoadingView(message: 'Calculando totales...'),
          error: (e, _) => ErrorView(
            message: e.toString(),
            onRetry: () => ref.invalidate(carritoCalculadoProvider),
          ),
          data: (calculo) => _buildFormByRol(context, ref, calculo, hPad),
        ),
      ),
    );
  }

  Widget _buildFormByRol(
    BuildContext context,
    WidgetRef ref,
    CarritoCalculado calculo,
    double hPad,
  ) {
    final user = ref.read(authProvider).user!;

    switch (user.roleSlug) {
      case 'distribuidor':
        return CheckoutDistribuidorForm(calculo: calculo, hPad: hPad);
      case 'negocio':
        return CheckoutNegocioForm(calculo: calculo, hPad: hPad);
      case 'consumidor':
      case 'profesional':
      default:
        return CheckoutConsumidorForm(calculo: calculo, hPad: hPad);
    }
  }
}
