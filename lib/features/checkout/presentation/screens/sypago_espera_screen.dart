import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../carrito/presentation/providers/cart_provider.dart';
import '../../../pedidos/presentation/providers/pedidos_providers.dart';

class SypagoEsperaScreen extends ConsumerStatefulWidget {
  final int pedidoId;
  const SypagoEsperaScreen({super.key, required this.pedidoId});

  @override
  ConsumerState<SypagoEsperaScreen> createState() => _SypagoEsperaScreenState();
}

class _SypagoEsperaScreenState extends ConsumerState<SypagoEsperaScreen> {
  Timer? _timer;
  int _intentos = 0;
  static const _maxIntentos = 30; // 30 intentos x 3 seg = 90 segundos

  String? _estadoFinal; // 'procesando' | 'rechazado' | 'pendiente'

  @override
  void initState() {
    super.initState();
    _iniciarPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _iniciarPolling() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      _intentos++;
      try {
        final pedido = await ref.read(
          pedidoDetalleProvider(widget.pedidoId).future,
        );

        if (!mounted) return;

        // Analizar estado
        if (pedido.pagado) {
          // Éxito
          timer.cancel();
          setState(() => _estadoFinal = 'aprobado');
          ref.invalidate(pedidosPaginadosProvider);
          // Vaciar carrito
          await ref.read(cartProvider.notifier).clear();
          return;
        }

        if (pedido.estado == 'rechazado') {
          timer.cancel();
          setState(() => _estadoFinal = 'rechazado');
          return;
        }

        if (_intentos >= _maxIntentos) {
          timer.cancel();
          setState(() => _estadoFinal = 'timeout');
        }
      } catch (_) {
        // Si hay error, seguir intentando
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
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
                child: _buildContenido(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContenido(BuildContext context) {
    if (_estadoFinal == null) {
      // Esperando
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: AppColors.secondary,
            strokeWidth: 4,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Verificando pago',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Estamos confirmando tu pago con el banco. Esto puede tomar unos segundos...',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Intento $_intentos de $_maxIntentos',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    }

    if (_estadoFinal == 'aprobado') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '¡Pago aprobado!',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tu pedido #${widget.pedidoId} está en proceso.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Ver mis pedidos',
            icon: Icons.receipt_long_outlined,
            onPressed: () => context.go('/pedidos'),
          ),
        ],
      );
    }

    if (_estadoFinal == 'rechazado') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cancel_outlined,
              size: 64,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Pago rechazado',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'El banco no autorizó el pago. Puedes intentarlo de nuevo o usar otro método de pago.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Volver al carrito',
            icon: Icons.arrow_back,
            onPressed: () => context.go('/catalogo'),
          ),
        ],
      );
    }

    // timeout
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.hourglass_empty,
            size: 64,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Verificación pendiente',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Tu pago aún está siendo procesado. Puedes verificar el estado en "Mis Pedidos" en unos minutos.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Ir a Mis Pedidos',
          icon: Icons.receipt_long_outlined,
          onPressed: () => context.go('/pedidos'),
        ),
      ],
    );
  }
}
