import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_bancos.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../carrito/presentation/providers/cart_provider.dart';
import '../../data/models/carrito_calculado.dart';
import '../providers/checkout_providers.dart';
import '../widgets/checkout_resumen.dart';
import '../../../catalogo/presentation/providers/catalog_providers.dart';

class CheckoutNegocioForm extends ConsumerStatefulWidget {
  final CarritoCalculado calculo;
  final double hPad;

  const CheckoutNegocioForm({
    super.key,
    required this.calculo,
    required this.hPad,
  });

  @override
  ConsumerState<CheckoutNegocioForm> createState() =>
      CheckoutNegocioFormState();
}

class CheckoutNegocioFormState extends ConsumerState<CheckoutNegocioForm> {
  final _formKey = GlobalKey<FormState>();

  // Pago
  final _refCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _cedulaCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  String? _bancoOrigen;

  // Cliente destino
  final _cdNombreCtrl = TextEditingController();
  final _cdApellidoCtrl = TextEditingController();
  final _cdCedulaCtrl = TextEditingController();
  final _cdTelefonoCtrl = TextEditingController();
  final _cdDireccionCtrl = TextEditingController();
  final _cdObservacionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _cedulaCtrl.text = user?.documentoIdentidad ?? '';
    _direccionCtrl.text = user?.direccion ?? '';
    _montoCtrl.text = widget.calculo.total.toStringAsFixed(2);
    _fechaCtrl.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Cargar tasa actual y calcular monto en Bs
    _cargarMontoBs();
  }

  Future<void> _cargarMontoBs() async {
    try {
      final tasa = await ref.read(tasaActualProvider.future);
      final montoBs = widget.calculo.total * tasa.valor;
      if (!mounted) return;
      _montoCtrl.text = montoBs.toStringAsFixed(2);
    } catch (_) {
      // Si falla la tasa, dejamos el monto en USD (fallback)
      _montoCtrl.text = widget.calculo.total.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _refCtrl.dispose();
    _montoCtrl.dispose();
    _fechaCtrl.dispose();
    _cedulaCtrl.dispose();
    _direccionCtrl.dispose();
    _notasCtrl.dispose();
    _cdNombreCtrl.dispose();
    _cdApellidoCtrl.dispose();
    _cdCedulaCtrl.dispose();
    _cdTelefonoCtrl.dispose();
    _cdDireccionCtrl.dispose();
    _cdObservacionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final cartItems = ref.read(cartProvider).items;
    final pedidoId = await ref
        .read(checkoutProvider.notifier)
        .crearPedido(
          items: cartItems,
          numeroReferencia: _refCtrl.text.trim(),
          monto: double.parse(_montoCtrl.text),
          fechaPago: _fechaCtrl.text,
          cedulaIdentidad: _cedulaCtrl.text.trim(),
          bancoOrigen: _bancoOrigen!,
          bancoDestino: AppBancos.bancoDestinoDefault,
          direccionEnvio: _direccionCtrl.text.trim(),
          notas: _notasCtrl.text.trim(),
          clienteDestino: {
            'nombre': _cdNombreCtrl.text.trim(),
            'apellido': _cdApellidoCtrl.text.trim(),
            'cedula': _cdCedulaCtrl.text.trim(),
            'telefono': _cdTelefonoCtrl.text.trim(),
            'direccion': _cdDireccionCtrl.text.trim(),
            if (_cdObservacionCtrl.text.trim().isNotEmpty)
              'observacion': _cdObservacionCtrl.text.trim(),
          },
        );

    if (!mounted) return;
    if (pedidoId != null) {
      await ref.read(cartProvider.notifier).clear();
      if (!mounted) return;
      context.go('/pedido-confirmado/$pedidoId');
    } else {
      final err = ref.read(checkoutProvider).error ?? 'Error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(checkoutProvider.select((s) => s.loading));

    return SingleChildScrollView(
      padding: EdgeInsets.all(widget.hPad),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pago
            _SectionTitle('Datos del Pago'),
            const SizedBox(height: AppSpacing.sm),
            _PagoMovilInfo(),
            const SizedBox(height: AppSpacing.lg),

            AppTextField(
              label: 'Número de referencia *',
              controller: _refCtrl,
              prefixIcon: const Icon(Icons.numbers),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            AppTextField(
              label: 'Monto (Bs) *',
              controller: _montoCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              prefixIcon: const Icon(Icons.attach_money),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requerido';
                if (double.tryParse(v) == null) return 'Monto inválido';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),

            AppTextField(
              label: 'Fecha del pago *',
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
            const SizedBox(height: AppSpacing.lg),

            // Dirección
            _SectionTitle('Dirección de envío'),
            const SizedBox(height: AppSpacing.sm),
            AppTextField(
              label: 'Dirección *',
              controller: _direccionCtrl,
              prefixIcon: const Icon(Icons.home_outlined),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            // Cliente destino
            _SectionTitle('Cliente destino'),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: AppRadius.mdAll,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.warning,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Datos de quien recibe',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Nombre *',
                    controller: _cdNombreCtrl,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: 'Apellido *',
                    controller: _cdApellidoCtrl,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: 'Cédula *',
                    controller: _cdCedulaCtrl,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: 'Teléfono *',
                    controller: _cdTelefonoCtrl,
                    keyboardType: TextInputType.phone,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: 'Dirección de envío *',
                    controller: _cdDireccionCtrl,
                    maxLines: 2,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: 'Observaciones',
                    hint: 'Empresa de envío, referencias, etc.',
                    controller: _cdObservacionCtrl,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Notas
            AppTextField(
              label: 'Notas adicionales',
              controller: _notasCtrl,
              maxLines: 2,
              prefixIcon: const Icon(Icons.notes),
            ),
            const SizedBox(height: AppSpacing.xl),

            CheckoutResumen(
              calculo: widget.calculo,
              onConfirm: _submit,
              loading: loading,
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _fechaCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
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

class _PagoMovilInfo extends StatelessWidget {
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
