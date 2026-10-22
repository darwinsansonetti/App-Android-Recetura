import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/async_value_widget.dart';
import '../../../pedidos/presentation/providers/pedidos_providers.dart';

class PedidoConfirmadoScreen extends ConsumerWidget {
  final int pedidoId;
  const PedidoConfirmadoScreen({super.key, required this.pedidoId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPedido = ref.watch(pedidoDetalleProvider(pedidoId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AsyncValueWidget(
          value: asyncPedido,
          data: (pedido) {
            final aprobado = pedido.pagado;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.lgAll,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: aprobado
                                ? AppColors.success.withValues(alpha: 0.12)
                                : AppColors.info.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            aprobado
                                ? Icons.check_circle_outline
                                : Icons.hourglass_empty,
                            size: 64,
                            color: aprobado
                                ? AppColors.success
                                : AppColors.info,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          aprobado ? '¡Pago Verificado!' : '¡Pedido creado!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          aprobado
                              ? 'Tu pago fue verificado automáticamente y tu pedido #$pedidoId ya está en proceso.'
                              : 'Tu pedido #$pedidoId está en revisión. Te notificaremos cuando se apruebe el pago.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        AppButton(
                          label: 'Ver mis pedidos',
                          icon: Icons.receipt_long_outlined,
                          onPressed: () => context.go('/pedidos'),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/catalogo'),
                          icon: const Icon(Icons.storefront_outlined),
                          label: const Text('Volver al catálogo'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}