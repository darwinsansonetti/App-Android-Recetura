import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/async_value_widget.dart';
import '../../data/models/distribuidor_detalle.dart';
import '../providers/aliado_providers.dart';

class DistribuidorDetalleScreen extends ConsumerWidget {
  final int id;
  const DistribuidorDetalleScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(distribuidorDetalleProvider(id));
    final hPad = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detalle del Distribuidor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(distribuidorDetalleProvider(id)),
          ),
        ],
      ),
      body: AsyncValueWidget<DistribuidorDetalle>(
        value: async,
        data: (detalle) => ListView(
          padding: EdgeInsets.all(hPad),
          children: [
            _UsuarioCard(detalle: detalle),
            const SizedBox(height: AppSpacing.lg),
            _StatsGrid(detalle: detalle),
            const SizedBox(height: AppSpacing.lg),
            _AccionesDistribuidor(
              id: id,
              nombre: detalle.usuario.nombreCompleto,
            ),
            const SizedBox(height: AppSpacing.lg),
            _PedidosList(detalle: detalle),
          ],
        ),
      ),
    );
  }
}

class _UsuarioCard extends StatelessWidget {
  final DistribuidorDetalle detalle;
  const _UsuarioCard({required this.detalle});

  @override
  Widget build(BuildContext context) {
    final u = detalle.usuario;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                child: Text(
                  u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u.nombreCompleto,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(u.email, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          if (u.celular != null || u.telefono != null) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            if (u.celular != null)
              _infoRow(Icons.phone_android, 'Celular', u.celular!),
            if (u.telefono != null)
              _infoRow(Icons.phone, 'Teléfono', u.telefono!),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$label: ',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final DistribuidorDetalle detalle;
  const _StatsGrid({required this.detalle});

  @override
  Widget build(BuildContext context) {
    final s = detalle.estadisticas;
    return Row(
      children: [
        Expanded(
          child: _MiniStat(
            label: 'Pedidos',
            value: s.totalPedidos.toString(),
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MiniStat(
            label: 'Pendientes',
            value: s.pedidosPendientes.toString(),
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MiniStat(
            label: 'Completados',
            value: s.pedidosCompletados.toString(),
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MiniStat(
            label: 'Deuda',
            value: '\$${s.deudaTotal.toStringAsFixed(2)}',
            color: s.deudaTotal > 0 ? AppColors.error : AppColors.success,
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AccionesDistribuidor extends ConsumerWidget {
  final int id;
  final String nombre;
  const _AccionesDistribuidor({required this.id, required this.nombre});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Acciones',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => _verPassword(context, ref),
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Ver contraseña actual'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => _resetPassword(context, ref),
            icon: const Icon(Icons.lock_reset),
            label: const Text('Resetear contraseña'),
          ),
        ],
      ),
    );
  }

  Future<void> _verPassword(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<({String password, String nombre})?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => FutureBuilder(
        future: ref.read(aliadoRepositoryProvider).getPasswordVisible(id),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          }
          if (snap.hasError) {
            return AlertDialog(
              title: const Text('Error'),
              content: Text(snap.error.toString()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          }
          final data = snap.data;
          if (data == null) {
            return AlertDialog(
              title: const Text('Contraseña no disponible'),
              content: const Text(
                'El distribuidor ya cambió su contraseña, por lo que no se puede mostrar la original.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          }
          return AlertDialog(
            title: const Text('Contraseña'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Usuario: ${data.nombre}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                SelectableText(
                  data.password,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: data.password));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contraseña copiada')),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copiar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      ),
    );
    if (result != null && context.mounted) {
      // Solo para cerrar el future builder
    }
  }

  Future<void> _resetPassword(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resetear contraseña'),
        content: Text(
          'Se generará una nueva contraseña para $nombre. La anterior dejará de funcionar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Resetear'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    if (!context.mounted) return;

    try {
      final result = await ref.read(aliadoRepositoryProvider).resetPassword(id);
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Contraseña reseteada'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Email: ${result.email}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              SelectableText(
                result.passwordGenerado,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: result.passwordGenerado));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contraseña copiada')),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copiar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }
}

class _PedidosList extends StatelessWidget {
  final DistribuidorDetalle detalle;
  const _PedidosList({required this.detalle});

  @override
  Widget build(BuildContext context) {
    final pedidos = detalle.pedidos;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Pedidos',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '${pedidos.length}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (pedidos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(
                'Sin pedidos todavía',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pedidos.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final p = pedidos[i];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    p['numero_pedido']?.toString() ?? 'Pedido',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Estado: ${p['estado'] ?? 'N/A'} · Total: \$${p['total'] ?? 0}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
