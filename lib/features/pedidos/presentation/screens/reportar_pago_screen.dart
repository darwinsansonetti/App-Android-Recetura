import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_bancos.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/async_value_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../catalogo/presentation/providers/catalog_providers.dart';
import '../../data/models/estado_cuenta.dart';
import '../providers/pagos_providers.dart';
import '../providers/pedidos_providers.dart';

class ReportarPagoScreen extends ConsumerStatefulWidget {
  final int pedidoId;
  const ReportarPagoScreen({super.key, required this.pedidoId});

  @override
  ConsumerState<ReportarPagoScreen> createState() => _ReportarPagoScreenState();
}

class _ReportarPagoScreenState extends ConsumerState<ReportarPagoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _refCtrl = TextEditingController();
  final _montoBsCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _cedulaCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();

  String? _bancoOrigen;
  double _tasa = 1.0;

  @override
  void initState() {
    super.initState();
    _fechaCtrl.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final user = ref.read(authProvider).user;
    _cedulaCtrl.text = user?.documentoIdentidad ?? '';

    // Cargar tasa actual
    _cargarTasa();
  }

  Future<void> _cargarTasa() async {
    try {
      final tasa = await ref.read(tasaActualProvider.future);
      if (!mounted) return;
      setState(() {
        _tasa = tasa.valor;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _refCtrl.dispose();
    _montoBsCtrl.dispose();
    _fechaCtrl.dispose();
    _cedulaCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  /// Setea el monto en Bs a partir de un monto en USD
  void _setMontoDesdeUsd(double montoUsd) {
    final montoBs = montoUsd * _tasa;
    _montoBsCtrl.text = montoBs.toStringAsFixed(2);
  }

  Future<void> _submit(EstadoCuenta estado) async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final monto = double.parse(_montoBsCtrl.text);
    final montoUsd = monto / _tasa;

    // Validación: monto no puede exceder el saldo pendiente
    if (montoUsd > estado.saldoPendienteUsd + 0.01) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El monto supera el saldo pendiente'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final id = await ref
        .read(reportarPagoProvider.notifier)
        .reportar(
          pedidoId: widget.pedidoId,
          numeroReferencia: _refCtrl.text.trim(),
          monto: monto,
          fechaPago: _fechaCtrl.text,
          cedulaIdentidad: _cedulaCtrl.text.trim(),
          bancoOrigen: _bancoOrigen!,
          bancoDestino: AppBancos.bancoDestinoDefault,
          notas: _notasCtrl.text.trim(),
        );

    if (!mounted) return;
    if (id != null) {
      // Invalidar el detalle del pedido para que se refresque
      ref.invalidate(pedidoDetalleProvider(widget.pedidoId));
      ref.invalidate(estadoCuentaProvider(widget.pedidoId));

      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Pago reportado'),
          content: const Text(
            'Tu pago fue reportado y está en revisión. Te notificaremos cuando sea aprobado.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      context.pop();
    } else {
      final err = ref.read(reportarPagoProvider).error ?? 'Error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncEstado = ref.watch(estadoCuentaProvider(widget.pedidoId));
    final loading = ref.watch(reportarPagoProvider.select((s) => s.loading));
    final hPad = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Reportar Pago')),
      body: AsyncValueWidget<EstadoCuenta>(
        value: asyncEstado,
        data: (estado) => SingleChildScrollView(
          padding: EdgeInsets.all(hPad),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ===== Estado de cuenta =====
                _CardEstadoCuenta(estado: estado, tasa: _tasa),
                const SizedBox(height: AppSpacing.lg),

                // ===== Botones rápidos de monto =====
                _BotonesMonto(
                  estado: estado,
                  tasa: _tasa,
                  onSelect: _setMontoDesdeUsd,
                ),
                const SizedBox(height: AppSpacing.lg),

                // ===== Formulario =====
                _SectionTitle('Datos del pago'),
                const SizedBox(height: AppSpacing.sm),
                const _PagoMovilInfo(),
                const SizedBox(height: AppSpacing.lg),

                AppTextField(
                  label: 'Número de referencia *',
                  hint: 'Ej: 123456789',
                  controller: _refCtrl,
                  prefixIcon: const Icon(Icons.numbers),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  label: 'Monto (Bs) *',
                  hint: '0.00',
                  controller: _montoBsCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    final d = double.tryParse(v);
                    if (d == null) return 'Monto inválido';
                    if (d <= 0) return 'Debe ser mayor a 0';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  label: 'Fecha del pago *',
                  hint: 'YYYY-MM-DD',
                  controller: _fechaCtrl,
                  readOnly: true,
                  onTap: _pickFecha,
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  label: 'Cédula de identidad *',
                  controller: _cedulaCtrl,
                  prefixIcon: const Icon(Icons.badge_outlined),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: AppSpacing.md),

                DropdownButtonFormField<String>(
                  initialValue: _bancoOrigen,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Banco origen *',
                    prefixIcon: Icon(Icons.account_balance_outlined),
                  ),
                  items: AppBancos.lista
                      .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                      .toList(),
                  onChanged: (v) => setState(() => _bancoOrigen = v),
                  validator: (v) => v == null ? 'Selecciona tu banco' : null,
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  label: 'Banco destino',
                  controller: TextEditingController(
                    text: AppBancos.bancoDestinoDefault,
                  ),
                  readOnly: true,
                  prefixIcon: const Icon(Icons.account_balance),
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  label: 'Notas',
                  hint: 'Información adicional (opcional)',
                  controller: _notasCtrl,
                  maxLines: 2,
                  prefixIcon: const Icon(Icons.notes),
                ),
                const SizedBox(height: AppSpacing.xl),

                AppButton(
                  label: 'Reportar pago',
                  icon: Icons.upload_outlined,
                  loading: loading,
                  onPressed: () => _submit(estado),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 60)),
      lastDate: DateTime.now(),
      helpText: 'Fecha del pago',
    );
    if (picked != null) {
      setState(() {
        _fechaCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }
}

// ============ Card estado de cuenta ============

class _CardEstadoCuenta extends StatelessWidget {
  final EstadoCuenta estado;
  final double tasa;
  const _CardEstadoCuenta({required this.estado, required this.tasa});

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
          const SizedBox(height: 2),
          Text(
            estado.numeroPedido,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),

          _row('Total del pedido', estado.total, AppColors.textPrimary),
          _row('Pagado', estado.totalPagadoUsd, AppColors.success),
          const Divider(height: 20),
          _row(
            'Saldo pendiente',
            estado.saldoPendienteUsd,
            estado.saldoPendienteUsd > 0 ? AppColors.error : AppColors.success,
            bold: true,
          ),

          // Saldo en Bs
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Bs. ${(estado.saldoPendienteUsd * tasa).toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // Aviso de descuento
          if (estado.puedePagarConDescuento &&
              estado.diasRestantesDescuento > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: AppRadius.mdAll,
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_offer,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Paga dentro de ${estado.diasRestantesDescuento} días y ahorra \$${estado.montoDescuento.toStringAsFixed(2)}!',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Total con descuento: \$${estado.totalConDescuento.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Aviso de pago pendiente
          if (estado.tienePagoPendiente) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: AppRadius.mdAll,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.hourglass_empty,
                    color: AppColors.warning,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ya tienes un pago pendiente de aprobación',
                      style: Theme.of(context).textTheme.bodySmall,
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

  Widget _row(String label, double valor, Color color, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: bold ? 14 : 13,
                fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            '\$${valor.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: bold ? 16 : 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ============ Botones rápidos de monto ============

class _BotonesMonto extends StatelessWidget {
  final EstadoCuenta estado;
  final double tasa;
  final ValueChanged<double> onSelect;

  const _BotonesMonto({
    required this.estado,
    required this.tasa,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final opciones = <_OpcionMonto>[];

    // Total con descuento
    if (estado.puedePagarConDescuento) {
      opciones.add(
        _OpcionMonto(
          label: 'Total con descuento',
          montoUsd: estado.totalConDescuento,
          destacado: true,
        ),
      );
    }

    // Saldo completo
    opciones.add(
      _OpcionMonto(label: 'Saldo completo', montoUsd: estado.saldoPendienteUsd),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle('¿Cuánto deseas pagar?'),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: opciones
              .map(
                (o) => _BotonMontoOpcion(
                  opcion: o,
                  tasa: tasa,
                  onTap: () => onSelect(o.montoUsd),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _OpcionMonto {
  final String label;
  final double montoUsd;
  final bool destacado;
  const _OpcionMonto({
    required this.label,
    required this.montoUsd,
    this.destacado = false,
  });
}

class _BotonMontoOpcion extends StatelessWidget {
  final _OpcionMonto opcion;
  final double tasa;
  final VoidCallback onTap;

  const _BotonMontoOpcion({
    required this.opcion,
    required this.tasa,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = opcion.destacado ? AppColors.success : AppColors.secondary;
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: AppRadius.pillAll,
      child: InkWell(
        borderRadius: AppRadius.pillAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                opcion.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                '\$${opcion.montoUsd.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============ Info pago móvil ============

class _PagoMovilInfo extends StatelessWidget {
  const _PagoMovilInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: AppRadius.mdAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.mobile_friendly, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Pago Móvil',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _infoRow('Teléfono', AppBancos.pagoMovilTelefono),
          _infoRow('Banco', AppBancos.pagoMovilBanco),
          _infoRow('Documento', AppBancos.pagoMovilDocumento),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: AppColors.textSecondary,
      ),
    );
  }
}
