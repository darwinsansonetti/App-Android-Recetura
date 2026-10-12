import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/async_value_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/pedido.dart';
import '../../data/models/pedido_detalle_item.dart';
import '../../data/models/pedido_transaccion.dart';
import '../providers/pedidos_providers.dart';
import 'package:go_router/go_router.dart';

class PedidoDetalleScreen extends ConsumerWidget {
  final int pedidoId;
  final bool esVistaAliado;
  const PedidoDetalleScreen({
    super.key,
    required this.pedidoId,
    this.esVistaAliado = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      pedidoDetalleVistaProvider((id: pedidoId, esAliado: esVistaAliado)),
    );
    final user = ref.watch(authProvider).user;
    final hPad = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detalle del pedido')),
      body: AsyncValueWidget<Pedido>(
        value: async,
        data: (pedido) => ListView(
          padding: EdgeInsets.all(hPad),
          children: [
            // Si viene del panel del Aliado, mostrar info del distribuidor
            if (esVistaAliado && pedido.user != null) ...[
              _CardDistribuidor(user: pedido.user!),
              const SizedBox(height: AppSpacing.lg),
            ],

            _SeccionProductos(pedido: pedido),
            const SizedBox(height: AppSpacing.lg),

            _SeccionTotales(pedido: pedido),
            const SizedBox(height: AppSpacing.lg),

            if (pedido.transacciones.isNotEmpty) ...[
              _SeccionPago(transacciones: pedido.transacciones),
              const SizedBox(height: AppSpacing.lg),
            ],

            if (pedido.clienteDestino != null) ...[
              _SeccionClienteDestino(data: pedido.clienteDestino!),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Sección especial para distribuidores
            if (user?.esDistribuidor == true) ...[
              _SeccionEstadoCuenta(pedido: pedido),
              const SizedBox(height: AppSpacing.lg),

              if (pedido.puedePagar) _BotonReportarPago(pedidoId: pedido.id),
            ],

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

// ============ PRODUCTOS ============

class _SeccionProductos extends StatelessWidget {
  final Pedido pedido;
  const _SeccionProductos({required this.pedido});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Productos',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          ...pedido.detalles.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _ItemProducto(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemProducto extends StatelessWidget {
  final PedidoDetalleItem item;
  const _ItemProducto({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: AppRadius.smAll,
          child: SizedBox(
            width: 56,
            height: 56,
            child: _ImagenProducto(url: item.producto.imagen),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.producto.nombre,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (item.producto.presentacion != null) ...[
                const SizedBox(height: 2),
                Text(
                  item.producto.presentacion!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 2),
              Text(
                '${item.cantidad} × \$${item.precioAplicado.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Text(
          '\$${item.subtotal.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _ImagenProducto extends StatelessWidget {
  final String? url;
  const _ImagenProducto({this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        color: AppColors.background,
        child: const Center(
          child: Icon(
            Icons.medication_outlined,
            size: 24,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.contain,
      placeholder: (_, _) => Container(color: AppColors.background),
      errorWidget: (_, _, _) => Container(
        color: AppColors.background,
        child: const Center(
          child: Icon(
            Icons.medication_outlined,
            size: 24,
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

// ============ TOTALES ============

class _SeccionTotales extends StatelessWidget {
  final Pedido pedido;
  const _SeccionTotales({required this.pedido});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _linea('Subtotal', pedido.subtotal),
          const SizedBox(height: 4),
          if (pedido.descuento > 0) ...[
            _linea('Descuento', -pedido.descuento, color: AppColors.success),
            const SizedBox(height: 4),
          ],
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          _linea('Total', pedido.total, bold: true, color: AppColors.secondary),
        ],
      ),
    );
  }

  Widget _linea(String label, double valor, {bool bold = false, Color? color}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: bold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          '\$${valor.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: bold ? 18 : 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ============ PAGO / TRANSACCIONES ============

class _SeccionPago extends StatelessWidget {
  final List<PedidoTransaccion> transacciones;
  const _SeccionPago({required this.transacciones});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            transacciones.length == 1 ? 'Pago' : 'Pagos / Abonos',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          ...transacciones.map((t) => _TransaccionCard(t: t)),
        ],
      ),
    );
  }
}

class _TransaccionCard extends StatelessWidget {
  final PedidoTransaccion t;
  const _TransaccionCard({required this.t});

  @override
  Widget build(BuildContext context) {
    final color = Color(t.estatusColorValue);
    final fecha = t.createdAt != null
        ? DateFormat('dd/MM/yyyy', 'es').format(t.createdAt!)
        : t.fechaPago;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Ref: ${t.numeroReferencia}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: AppRadius.pillAll,
                ),
                child: Text(
                  t.estatusTexto,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _row('Monto', 'Bs. ${t.monto.toStringAsFixed(2)}'),
          _row('Equivalente', '\$${t.montoDivisa.toStringAsFixed(2)}'),
          _row('Fecha pago', fecha),
          if (t.bancoOrigen != null) _row('Banco origen', t.bancoOrigen!),
          if (t.cedulaIdentidad != null) _row('Cédula', t.cedulaIdentidad!),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ CLIENTE DESTINO ============

class _SeccionClienteDestino extends StatelessWidget {
  final Map<String, dynamic> data;
  const _SeccionClienteDestino({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.06),
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_pin_circle_outlined,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'Cliente destino',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _row('Nombre', '${data['nombre'] ?? ''} ${data['apellido'] ?? ''}'),
          if (data['cedula'] != null) _row('Cédula', data['cedula']),
          if (data['telefono'] != null) _row('Teléfono', data['telefono']),
          if (data['direccion'] != null) _row('Dirección', data['direccion']),
          if (data['observacion'] != null)
            _row('Observación', data['observacion']),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ============ ESTADO DE CUENTA (DISTRIBUIDOR) ============

class _SeccionEstadoCuenta extends StatelessWidget {
  final Pedido pedido;
  const _SeccionEstadoCuenta({required this.pedido});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estado de cuenta',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),

          _rowSaldo('Total del pedido', pedido.total, AppColors.textPrimary),
          _rowSaldo('Pagado', pedido.totalPagadoUsd, AppColors.success),
          _rowSaldo(
            'Saldo pendiente',
            pedido.saldoPendienteUsd,
            pedido.saldoPendienteUsd > 0 ? AppColors.error : AppColors.success,
          ),

          if (pedido.fechaLimitePago != null) ...[
            const SizedBox(height: AppSpacing.sm),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Fecha límite de pago: ${DateFormat('dd/MM/yyyy').format(pedido.fechaLimitePago!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],

          if (pedido.puedePagarConDescuento &&
              pedido.diasRestantesDescuento > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: AppRadius.smAll,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_offer,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Pagando dentro de ${pedido.diasRestantesDescuento} días obtienes ${pedido.montoDescuento.toStringAsFixed(2)} de descuento',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _rowSaldo(String label, double valor, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            '\$${valor.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ BOTÓN REPORTAR PAGO ============

class _BotonReportarPago extends StatelessWidget {
  final int pedidoId;
  const _BotonReportarPago({required this.pedidoId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: () => context.push('/pedidos/$pedidoId/reportar-pago'),
        icon: const Icon(Icons.upload_outlined),
        label: const Text('Reportar pago'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    );
  }
}

class _CardDistribuidor extends StatelessWidget {
  final Map<String, dynamic> user;
  const _CardDistribuidor({required this.user});

  @override
  Widget build(BuildContext context) {
    final nombre = (user['nombre_completo'] ?? user['name'] ?? '') as String;
    final email = (user['email'] ?? '') as String;
    final celular = user['celular'] as String?;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.06),
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_pin_circle_outlined,
                color: AppColors.info,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'Distribuidor',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            nombre,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(email, style: Theme.of(context).textTheme.bodySmall),
          if (celular != null && celular.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(celular, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
