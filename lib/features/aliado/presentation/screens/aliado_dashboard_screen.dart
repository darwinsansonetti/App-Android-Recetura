import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/async_value_widget.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../data/models/dashboard_data.dart';
import '../../data/models/dashboard_stats.dart';
import '../../data/models/pedido_resumen.dart';
import '../providers/aliado_providers.dart';

class AliadoDashboardScreen extends ConsumerWidget {
  const AliadoDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dashboardProvider);
    final filtro = ref.watch(dashboardFiltroProvider);
    final hPad = Responsive.horizontalPadding(context);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(dashboardProvider),
      child: AsyncValueWidget<DashboardData>(
        value: async,
        data: (data) => ListView(
          padding: EdgeInsets.symmetric(
            horizontal: hPad,
            vertical: AppSpacing.md,
          ),
          children: [
            // ===== Filtro de fechas =====
            _FiltroFechas(
              filtro: filtro,
              onChange: (nuevo) =>
                  ref.read(dashboardFiltroProvider.notifier).state = nuevo,
            ),
            const SizedBox(height: AppSpacing.lg),

            // ===== Stats =====
            _StatsGrid(stats: data.estadisticas),
            const SizedBox(height: AppSpacing.xl),

            // ===== Tabla/Cards de pedidos =====
            _PedidosSection(data: data),
          ],
        ),
      ),
    );
  }
}

// ============ FILTRO DE FECHAS ============

class _FiltroFechas extends StatelessWidget {
  final DashboardFiltro filtro;
  final ValueChanged<DashboardFiltro> onChange;

  const _FiltroFechas({required this.filtro, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final isWide = !Responsive.isMobile(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
      ),
      child: isWide
          ? Row(
              children: [
                Expanded(child: _fechaBtn(context, esInicio: true)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _fechaBtn(context, esInicio: false)),
                const SizedBox(width: AppSpacing.sm),
                _aplicarBtn(context, onChange),
              ],
            )
          : Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _fechaBtn(context, esInicio: true)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: _fechaBtn(context, esInicio: false)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: _aplicarBtn(context, onChange),
                ),
              ],
            ),
    );
  }

  Widget _fechaBtn(BuildContext context, {required bool esInicio}) {
    final fecha = esInicio ? filtro.fechaInicio : filtro.fechaFin;
    final label = esInicio ? 'Desde' : 'Hasta';
    final fmt = DateFormat('dd/MM/yyyy', 'es');

    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: fecha,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          helpText: esInicio ? 'Fecha inicio' : 'Fecha fin',
          cancelText: 'Cancelar',
          confirmText: 'Aceptar',
        );
        if (picked != null) {
          final nuevo = esInicio
              ? filtro.copyWith(fechaInicio: picked)
              : filtro.copyWith(fechaFin: picked);
          onChange(nuevo);
        }
      },
      icon: const Icon(Icons.calendar_today_outlined, size: 16),
      label: Text(
        '$label: ${fmt.format(fecha)}',
        style: const TextStyle(fontSize: 13),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }

  Widget _aplicarBtn(
    BuildContext context,
    ValueChanged<DashboardFiltro> onChange,
  ) {
    return FilledButton.icon(
      onPressed: () {
        // Fuerza re-fetch invalidando el provider (no cambia la fecha)
        onChange(filtro.copyWith());
      },
      icon: const Icon(Icons.filter_alt_outlined, size: 18),
      label: const Text('Aplicar'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }
}

// ============ STATS ============

class _StatsGrid extends StatelessWidget {
  final DashboardStats stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final isWide = !Responsive.isMobile(context);
    final cards = [
      _StatCard(
        label: 'Total pedidos',
        value: stats.totalPedidos.toString(),
        icon: Icons.receipt_long,
        color: AppColors.primary,
      ),
      _StatCard(
        label: 'Aprobados',
        value: stats.pedidosAprobados.toString(),
        icon: Icons.check_circle_outline,
        color: AppColors.success,
      ),
      _StatCard(
        label: 'Rechazados',
        value: stats.pedidosRechazados.toString(),
        icon: Icons.cancel_outlined,
        color: AppColors.error,
      ),
      _StatCard(
        label: 'Monto aprobado',
        value: '\$${stats.montoAprobados.toStringAsFixed(2)}',
        icon: Icons.attach_money,
        color: AppColors.secondary,
      ),
    ];

    return GridView.count(
      crossAxisCount: isWide ? 4 : 2,
      crossAxisSpacing: AppSpacing.md,
      mainAxisSpacing: AppSpacing.md,
      childAspectRatio: isWide ? 1.6 : 1.3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cards,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============ PEDIDOS (cards o tabla) ============

class _PedidosSection extends StatelessWidget {
  final DashboardData data;
  const _PedidosSection({required this.data});

  @override
  Widget build(BuildContext context) {
    final isWide = !Responsive.isMobile(context);
    final est = data.estadisticas;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pedidos de mis Usuarios',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            '${est.fechaInicio} al ${est.fechaFin}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),

          if (data.pedidos.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: EmptyView(
                icon: Icons.receipt_long_outlined,
                title: 'Sin pedidos en este período',
                subtitle: 'Prueba con otro rango de fechas',
              ),
            )
          else if (isWide)
            _PedidosTable(pedidos: data.pedidos)
          else
            _PedidosCards(pedidos: data.pedidos),

          if (data.pedidos.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Mostrando ${data.pedidos.length} de ${data.meta.total} pedidos',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _PedidosTable extends StatelessWidget {
  final List<PedidoResumen> pedidos;
  const _PedidosTable({required this.pedidos});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DataTable(
        columnSpacing: 16,
        horizontalMargin: 8,
        headingRowHeight: 40,
        dataRowMinHeight: 52,
        dataRowMaxHeight: 68,
        columns: const [
          DataColumn(label: Text('#')),
          DataColumn(label: Text('Pedido')),
          DataColumn(label: Text('Cliente')),
          DataColumn(label: Text('Total')),
          DataColumn(label: Text('Estado')),
          DataColumn(label: Text('Pago')),
          DataColumn(label: Text('Fecha')),
          DataColumn(label: Text('')),
        ],
        rows: pedidos.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value;
          return DataRow(
            cells: [
              DataCell(Text('${i + 1}')),
              DataCell(
                Text(
                  p.numeroPedido,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              DataCell(
                Text(
                  p.distribuidorNombre,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DataCell(
                Text(
                  '\$${p.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              DataCell(
                _EstadoChip(
                  texto: p.estadoTexto,
                  colorValue: p.estadoColorValue,
                ),
              ),
              DataCell(
                _PagoChip(
                  texto: p.pagoTexto ?? p.metodoPago ?? '-',
                  colorValue: p.pagoColorValue,
                ),
              ),
              DataCell(
                Text(
                  p.createdAt != null
                      ? DateFormat('dd/MM/yy').format(p.createdAt!)
                      : '-',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              DataCell(
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  tooltip: 'Ver detalle',
                  onPressed: () => context.push('/aliado/pedidos/${p.id}'),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _PedidosCards extends StatelessWidget {
  final List<PedidoResumen> pedidos;
  const _PedidosCards({required this.pedidos});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: pedidos
          .asMap()
          .entries
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _PedidoCard(index: e.key + 1, pedido: e.value),
            ),
          )
          .toList(),
    );
  }
}

class _PedidoCard extends StatelessWidget {
  final int index;
  final PedidoResumen pedido;
  const _PedidoCard({required this.index, required this.pedido});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        borderRadius: AppRadius.mdAll,
        onTap: () => context.push('/aliado/pedidos/${pedido.id}'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '#$index',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      pedido.numeroPedido,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '\$${pedido.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      pedido.distribuidorNombre,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    pedido.createdAt != null
                        ? DateFormat('dd/MM/yy').format(pedido.createdAt!)
                        : '-',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  _EstadoChip(
                    texto: pedido.estadoTexto,
                    colorValue: pedido.estadoColorValue,
                  ),
                  if (pedido.pagoTexto != null)
                    _PagoChip(
                      texto: pedido.pagoTexto!,
                      colorValue: pedido.pagoColorValue,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstadoChip extends StatelessWidget {
  final String texto;
  final int colorValue;
  const _EstadoChip({required this.texto, required this.colorValue});

  @override
  Widget build(BuildContext context) {
    final color = Color(colorValue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PagoChip extends StatelessWidget {
  final String texto;
  final int colorValue;
  const _PagoChip({required this.texto, required this.colorValue});

  @override
  Widget build(BuildContext context) {
    final color = Color(colorValue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.pillAll,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
