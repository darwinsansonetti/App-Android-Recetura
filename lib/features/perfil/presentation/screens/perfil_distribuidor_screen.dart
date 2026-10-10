import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/perfil_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PerfilDistribuidorScreen extends ConsumerStatefulWidget {
  const PerfilDistribuidorScreen({super.key});

  @override
  ConsumerState<PerfilDistribuidorScreen> createState() =>
      _PerfilDistribuidorScreenState();
}

class _PerfilDistribuidorScreenState
    extends ConsumerState<PerfilDistribuidorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _razonSocialCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();
  final _rifCtrl = TextEditingController();
  final _zonaCtrl = TextEditingController();
  final _municipioCtrl = TextEditingController();
  final _sicmCtrl = TextEditingController();
  final _maestroCtrl = TextEditingController();
  final _observacionCtrl = TextEditingController();
  String? _nacionalidad;
  bool _contribuyenteEspecial = false;

  @override
  void initState() {
    super.initState();

    // Pre-llenar el formulario con los datos actuales del distribuidor
    final user = ref.read(authProvider).user;
    final d = user?.distribuidor;

    if (d != null) {
      _razonSocialCtrl.text = d.razonSocial ?? '';
      _codigoCtrl.text = d.codigo ?? '';
      _rifCtrl.text = d.rif ?? '';
      _zonaCtrl.text = d.zona ?? '';
      _municipioCtrl.text = d.municipio ?? '';
      _sicmCtrl.text = d.sicm ?? '';
      _maestroCtrl.text = d.maestro ?? '';
      _observacionCtrl.text = d.observacion ?? '';
      _nacionalidad = d.nacionalidad;
      _contribuyenteEspecial = d.contribuyenteEspecial;
    }
  }

  @override
  void dispose() {
    _razonSocialCtrl.dispose();
    _codigoCtrl.dispose();
    _rifCtrl.dispose();
    _zonaCtrl.dispose();
    _municipioCtrl.dispose();
    _sicmCtrl.dispose();
    _maestroCtrl.dispose();
    _observacionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ref.read(perfilProvider.notifier).reset();

    final ok = await ref
        .read(perfilProvider.notifier)
        .actualizarDistribuidor(
          razonSocial: _razonSocialCtrl.text.trim(),
          codigo: _codigoCtrl.text.trim().isEmpty
              ? null
              : _codigoCtrl.text.trim(),
          rif: _rifCtrl.text.trim().isEmpty ? null : _rifCtrl.text.trim(),
          zona: _zonaCtrl.text.trim().isEmpty ? null : _zonaCtrl.text.trim(),
          municipio: _municipioCtrl.text.trim().isEmpty
              ? null
              : _municipioCtrl.text.trim(),
          nacionalidad: _nacionalidad,
          contribuyenteEspecial: _contribuyenteEspecial,
          sicm: _sicmCtrl.text.trim().isEmpty ? null : _sicmCtrl.text.trim(),
          maestro: _maestroCtrl.text.trim().isEmpty
              ? null
              : _maestroCtrl.text.trim(),
          observacion: _observacionCtrl.text.trim().isEmpty
              ? null
              : _observacionCtrl.text.trim(),
        );

    if (!mounted) return;
    if (ok) {
      await ref.read(authProvider.notifier).refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos del distribuidor actualizados'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      final err = ref.read(perfilProvider).error ?? 'Error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(perfilProvider.select((s) => s.loading));
    final hPad = Responsive.horizontalPadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Datos del distribuidor')),
      body: SafeArea(
        child: CenteredConstrained(
          maxWidth: 560,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(hPad),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: 'Razón social *',
                    controller: _razonSocialCtrl,
                    prefixIcon: const Icon(Icons.business_outlined),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Código',
                    controller: _codigoCtrl,
                    prefixIcon: const Icon(Icons.qr_code),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'RIF',
                    hint: 'J-1234567890',
                    controller: _rifCtrl,
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Zona',
                    controller: _zonaCtrl,
                    prefixIcon: const Icon(Icons.map_outlined),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Municipio',
                    controller: _municipioCtrl,
                    prefixIcon: const Icon(Icons.location_city_outlined),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: _nacionalidad,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Nacionalidad',
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'venezolano',
                        child: Text('Venezolano'),
                      ),
                      DropdownMenuItem(
                        value: 'extranjero',
                        child: Text('Extranjero'),
                      ),
                      DropdownMenuItem(
                        value: 'juridico',
                        child: Text('Jurídico'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _nacionalidad = v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SwitchListTile(
                    value: _contribuyenteEspecial,
                    onChanged: (v) =>
                        setState(() => _contribuyenteEspecial = v),
                    title: const Text('Contribuyente especial'),
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: AppColors.secondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'SICM',
                    controller: _sicmCtrl,
                    prefixIcon: const Icon(Icons.numbers),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Maestro',
                    controller: _maestroCtrl,
                    prefixIcon: const Icon(Icons.label_outline),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Observación',
                    controller: _observacionCtrl,
                    maxLines: 3,
                    prefixIcon: const Icon(Icons.notes),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  AppButton(
                    label: 'Guardar cambios',
                    icon: Icons.check,
                    loading: loading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
