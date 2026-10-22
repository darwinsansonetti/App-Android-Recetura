import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/sypago_providers.dart';

class SypagoFormScreen extends ConsumerStatefulWidget {
  final int pedidoId;
  const SypagoFormScreen({super.key, required this.pedidoId});

  @override
  ConsumerState<SypagoFormScreen> createState() => _SypagoFormScreenState();
}

class _SypagoFormScreenState extends ConsumerState<SypagoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _documentoCtrl = TextEditingController();
  final _cuentaCtrl = TextEditingController();

  String _documentoTipo = 'V';
  String? _bancoCodigo;
  String _cuentaTipo = 'CELE';

  static const _bancos = [
    ('0102', 'Banco de Venezuela'),
    ('0134', 'Banesco'),
    ('0105', 'Mercantil'),
    ('0108', 'BBVA Provincial'),
    ('0114', 'Bancaribe'),
    ('0115', 'Banco Exterior'),
    ('0172', 'Bancamiga'),
    ('0191', 'Banco Nacional de Crédito'),
    ('0175', 'Banco Bicentenario'),
    ('0163', 'Banco del Tesoro'),
    ('0151', 'Banco Fondo Común'),
    ('0156', '100% Banco'),
    ('0168', 'Banco Sofitasa'),
    ('0174', 'Banplus'),
    ('0104', 'Banco Venezolano de Crédito'),
    ('0110', 'Citi Venezuela'),
    ('0122', 'Banco Confederado'),
    ('0128', 'Banco Caroní'),
    ('0137', 'Banco Activo'),
    ('0138', 'Banco Plaza'),
    ('0146', 'Banco de la Mujer'),
    ('0164', 'Banco Nobel'),
    ('0177', 'BANFANB'),
    ('0184', 'Banco Federal'),
  ];

  @override
  void dispose() {
    _documentoCtrl.dispose();
    _cuentaCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final ok = await ref
        .read(sypagoProvider.notifier)
        .solicitarOtp(
          pedidoId: widget.pedidoId,
          documentoTipo: _documentoTipo,
          documentoNumero: _documentoCtrl.text.trim(),
          bancoCodigo: _bancoCodigo!,
          cuentaTipo: _cuentaTipo,
          cuentaNumero: _cuentaCtrl.text.trim(),
        );

    if (!mounted) return;
    if (ok) {
      context.pushReplacement('/sypago/${widget.pedidoId}/otp');
    } else {
      final err = ref.read(sypagoProvider).error ?? 'Error al enviar OTP';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(sypagoProvider.select((s) => s.loading));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pagar con SyPago')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.08),
                    borderRadius: AppRadius.mdAll,
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Recibirás un código OTP en tu teléfono para confirmar el pago. Asegúrate de tener disponible el celular asociado a tu cuenta bancaria.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Tipo documento
                Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: DropdownButtonFormField<String>(
                        initialValue: _documentoTipo,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Tipo',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'V', child: Text('V')),
                          DropdownMenuItem(value: 'E', child: Text('E')),
                          DropdownMenuItem(value: 'J', child: Text('J')),
                          DropdownMenuItem(value: 'P', child: Text('P')),
                        ],
                        onChanged: (v) =>
                            setState(() => _documentoTipo = v ?? 'V'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppTextField(
                        label: 'Documento *',
                        hint: '12345678',
                        controller: _documentoCtrl,
                        keyboardType: TextInputType.number,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Requerido'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Banco
                DropdownButtonFormField<String>(
                  initialValue: _bancoCodigo,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Banco emisor *',
                    prefixIcon: Icon(Icons.account_balance_outlined),
                  ),
                  items: _bancos
                      .map(
                        (b) => DropdownMenuItem(
                          value: b.$1,
                          child: Text('${b.$1} - ${b.$2}'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _bancoCodigo = v),
                  validator: (v) => v == null ? 'Selecciona tu banco' : null,
                ),
                const SizedBox(height: AppSpacing.md),

                // Tipo cuenta
                DropdownButtonFormField<String>(
                  initialValue: _cuentaTipo,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de cuenta *',
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'CELE',
                      child: Text('CELE - Celular (Pago Móvil)'),
                    ),
                    DropdownMenuItem(
                      value: 'CNTA',
                      child: Text('CNTA - Cuenta bancaria'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _cuentaTipo = v ?? 'CELE'),
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  label: _cuentaTipo == 'CELE'
                      ? 'Teléfono *'
                      : 'Número de cuenta *',
                  hint: _cuentaTipo == 'CELE' ? '04141234567' : '0001234567890',
                  controller: _cuentaCtrl,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_android),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: AppSpacing.xl),

                AppButton(
                  label: 'Enviar código OTP',
                  icon: Icons.send,
                  loading: loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
