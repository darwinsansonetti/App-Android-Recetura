import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/perfil_provider.dart';

class EditarPerfilScreen extends ConsumerStatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  ConsumerState<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends ConsumerState<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _apellidoCtrl;
  late final TextEditingController _telefonoCtrl;
  late final TextEditingController _celularCtrl;
  late final TextEditingController _documentoCtrl;
  late final TextEditingController _fechaCtrl;
  late final TextEditingController _direccionCtrl;
  late final TextEditingController _ciudadCtrl;
  late final TextEditingController _estadoCtrl;
  late final TextEditingController _paisCtrl;
  late final TextEditingController _codigoPostalCtrl;
  String? _genero;

  @override
  void initState() {
    super.initState();
    final u = ref.read(authProvider).user;

    _nameCtrl = TextEditingController(text: u?.name ?? '');
    _apellidoCtrl = TextEditingController(text: u?.apellido ?? '');
    _telefonoCtrl = TextEditingController(text: u?.telefono ?? '');
    _celularCtrl = TextEditingController(text: u?.celular ?? '');
    _documentoCtrl = TextEditingController(text: u?.documentoIdentidad ?? '');
    _fechaCtrl = TextEditingController(text: u?.fechaNacimiento ?? '');
    _direccionCtrl = TextEditingController(text: u?.direccion ?? '');
    _ciudadCtrl = TextEditingController(text: u?.ciudad ?? '');
    _estadoCtrl = TextEditingController(text: u?.estadoProvincia ?? '');
    _paisCtrl = TextEditingController(text: u?.pais ?? 'Venezuela');
    _codigoPostalCtrl = TextEditingController(text: u?.codigoPostal ?? '');
    _genero = _normalizeGenero(u?.genero);
  }

  String? _normalizeGenero(String? g) {
    if (g == null || g.isEmpty) return null;
    final l = g.toLowerCase();
    if (l.startsWith('m') || l == 'hombre') return 'masculino';
    if (l.startsWith('f') || l == 'mujer') return 'femenino';
    return 'otro';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _apellidoCtrl.dispose();
    _telefonoCtrl.dispose();
    _celularCtrl.dispose();
    _documentoCtrl.dispose();
    _fechaCtrl.dispose();
    _direccionCtrl.dispose();
    _ciudadCtrl.dispose();
    _estadoCtrl.dispose();
    _paisCtrl.dispose();
    _codigoPostalCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFecha() async {
    final now = DateTime.now();
    DateTime initial;
    try {
      initial = _fechaCtrl.text.isNotEmpty
          ? DateTime.parse(_fechaCtrl.text)
          : DateTime(now.year - 25);
    } catch (_) {
      initial = DateTime(now.year - 25);
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 13),
      helpText: 'Selecciona tu fecha de nacimiento',
    );
    if (picked != null) {
      final iso = picked.toIso8601String().split('T').first;
      setState(() => _fechaCtrl.text = iso);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ref.read(perfilProvider.notifier).reset();

    final ok = await ref
        .read(perfilProvider.notifier)
        .actualizarPerfil(
          name: _nameCtrl.text.trim(),
          apellido: _apellidoCtrl.text.trim(),
          telefono: _telefonoCtrl.text.trim(),
          celular: _celularCtrl.text.trim(),
          documentoIdentidad: _documentoCtrl.text.trim(),
          fechaNacimiento: _fechaCtrl.text.trim(),
          genero: _genero,
          direccion: _direccionCtrl.text.trim(),
          ciudad: _ciudadCtrl.text.trim(),
          estadoProvincia: _estadoCtrl.text.trim(),
          pais: _paisCtrl.text.trim(),
          codigoPostal: _codigoPostalCtrl.text.trim(),
        );

    if (!mounted) return;
    if (ok) {
      await ref.read(authProvider.notifier).refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado'),
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
      appBar: AppBar(title: const Text('Información personal')),
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
                  _SectionLabel(text: 'Datos básicos'),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: 'Nombre',
                    controller: _nameCtrl,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Apellido',
                    controller: _apellidoCtrl,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  _SectionLabel(text: 'Contacto'),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: 'Teléfono',
                    controller: _telefonoCtrl,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Celular',
                    controller: _celularCtrl,
                    keyboardType: TextInputType.phone,
                    prefixIcon: const Icon(Icons.phone_android),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  _SectionLabel(text: 'Identificación'),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: 'Documento de identidad',
                    controller: _documentoCtrl,
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Fecha de nacimiento',
                    hint: 'YYYY-MM-DD',
                    controller: _fechaCtrl,
                    readOnly: true,
                    onTap: _pickFecha,
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: _genero,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Género',
                      prefixIcon: Icon(Icons.wc_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'masculino',
                        child: Text('Masculino'),
                      ),
                      DropdownMenuItem(
                        value: 'femenino',
                        child: Text('Femenino'),
                      ),
                      DropdownMenuItem(value: 'otro', child: Text('Otro')),
                    ],
                    onChanged: (v) => setState(() => _genero = v),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  _SectionLabel(text: 'Dirección'),
                  const SizedBox(height: AppSpacing.sm),
                  AppTextField(
                    label: 'Dirección',
                    controller: _direccionCtrl,
                    prefixIcon: const Icon(Icons.home_outlined),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Ciudad',
                    controller: _ciudadCtrl,
                    prefixIcon: const Icon(Icons.location_city_outlined),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Estado / Provincia',
                    controller: _estadoCtrl,
                    prefixIcon: const Icon(Icons.map_outlined),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'País',
                    controller: _paisCtrl,
                    prefixIcon: const Icon(Icons.flag_outlined),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Código postal',
                    controller: _codigoPostalCtrl,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.markunread_mailbox_outlined),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  AppButton(
                    label: 'Guardar cambios',
                    icon: Icons.check,
                    loading: loading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: AppColors.textSecondary,
      ),
    );
  }
}
