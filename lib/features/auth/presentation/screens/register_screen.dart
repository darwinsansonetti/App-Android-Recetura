import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _celularCtrl = TextEditingController();
  final _documentoCtrl = TextEditingController();
  final _fechaCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  String? _genero;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _aceptaTerminos = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _apellidoCtrl.dispose();
    _emailCtrl.dispose();
    _celularCtrl.dispose();
    _documentoCtrl.dispose();
    _fechaCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFecha() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 13),
      helpText: 'Selecciona tu fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (picked != null) {
      final iso = picked.toIso8601String().split('T').first;
      setState(() => _fechaCtrl.text = iso);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los Términos y Condiciones'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    FocusScope.of(context).unfocus();

    final ok = await ref
        .read(authProvider.notifier)
        .register(
          name: _nameCtrl.text.trim(),
          apellido: _apellidoCtrl.text.trim().isEmpty
              ? null
              : _apellidoCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          celular: _celularCtrl.text.trim().isEmpty
              ? null
              : _celularCtrl.text.trim(),
          documentoIdentidad: _documentoCtrl.text.trim().isEmpty
              ? null
              : _documentoCtrl.text.trim(),
          fechaNacimiento: _fechaCtrl.text.isEmpty ? null : _fechaCtrl.text,
          genero: _genero,
        );

    if (!mounted) return;
    if (ok) {
      context.go('/home');
    } else {
      final err = ref.read(authProvider).error ?? 'Error al registrarse';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authProvider.select((s) => s.loading));
    final hPad = Responsive.horizontalPadding(context);
    final isWide = !Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/login');
            }
          },
        ),
      ),
      body: SafeArea(
        top: false,
        child: CenteredConstrained(
          maxWidth: 520, // Igual de centrado que el login
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: hPad,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ===== Card blanca con sombra (igual que login) =====
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.xxl,
                  ),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo
                        const Center(child: AppLogo(height: 90)),
                        const SizedBox(height: AppSpacing.xl),

                        // Título
                        Text(
                          'Crear Cuenta',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),

                        // Subtítulo
                        Text(
                          'Regístrate para comenzar a comprar',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        // Campos
                        if (isWide) ...[
                          Row(
                            children: [
                              Expanded(child: _nombreField()),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(child: _apellidoField()),
                            ],
                          ),
                        ] else ...[
                          _nombreField(),
                          const SizedBox(height: AppSpacing.lg),
                          _apellidoField(),
                        ],
                        const SizedBox(height: AppSpacing.lg),

                        AppTextField(
                          label: 'Correo Electrónico *',
                          hint: 'tu@correo.com',
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Correo requerido';
                            }
                            if (!v.contains('@') || !v.contains('.')) {
                              return 'Correo inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        AppTextField(
                          label: 'Celular',
                          hint: '04141234567',
                          controller: _celularCtrl,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.phone_android),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        AppTextField(
                          label: 'Documento de Identidad',
                          hint: 'V-12345678',
                          controller: _documentoCtrl,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.badge_outlined),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        if (isWide) ...[
                          Row(
                            children: [
                              Expanded(child: _fechaField()),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(child: _generoField()),
                            ],
                          ),
                        ] else ...[
                          _fechaField(),
                          const SizedBox(height: AppSpacing.lg),
                          _generoField(),
                        ],
                        const SizedBox(height: AppSpacing.lg),

                        if (isWide) ...[
                          Row(
                            children: [
                              Expanded(child: _passwordField()),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(child: _confirmField()),
                            ],
                          ),
                        ] else ...[
                          _passwordField(),
                          const SizedBox(height: AppSpacing.lg),
                          _confirmField(),
                        ],
                        const SizedBox(height: AppSpacing.lg),

                        // Términos
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _aceptaTerminos,
                                onChanged: (v) => setState(
                                  () => _aceptaTerminos = v ?? false,
                                ),
                                activeColor: AppColors.secondary,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _aceptaTerminos = !_aceptaTerminos,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                    children: const [
                                      TextSpan(text: 'Acepto los '),
                                      TextSpan(
                                        text: 'Términos y Condiciones',
                                        style: TextStyle(
                                          color: AppColors.secondary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' *',
                                        style: TextStyle(
                                          color: AppColors.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // Botón
                        AppButton(
                          label: 'Registrarse',
                          icon: Icons.person_add_alt_1,
                          loading: loading,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Link a login (fuera del card, igual que login)
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    '¿Ya tienes cuenta? Inicia sesión',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================== Campos =====================

  Widget _nombreField() => AppTextField(
    label: 'Nombre *',
    controller: _nameCtrl,
    textInputAction: TextInputAction.next,
    prefixIcon: const Icon(Icons.person_outline),
    validator: (v) =>
        (v == null || v.trim().length < 2) ? 'Mínimo 2 caracteres' : null,
  );

  Widget _apellidoField() => AppTextField(
    label: 'Apellido',
    controller: _apellidoCtrl,
    textInputAction: TextInputAction.next,
    prefixIcon: const Icon(Icons.person_outline),
  );

  Widget _fechaField() => AppTextField(
    label: 'Fecha de nacimiento',
    hint: 'dd/mm/aaaa',
    controller: _fechaCtrl,
    readOnly: true,
    onTap: _pickFecha,
    prefixIcon: const Icon(Icons.calendar_today_outlined),
  );

  Widget _generoField() => DropdownButtonFormField<String>(
    initialValue: _genero,
    isExpanded: true,
    decoration: const InputDecoration(
      labelText: 'Género',
      prefixIcon: Icon(Icons.wc_outlined),
    ),
    items: const [
      DropdownMenuItem(value: 'masculino', child: Text('Masculino')),
      DropdownMenuItem(value: 'femenino', child: Text('Femenino')),
      DropdownMenuItem(value: 'otro', child: Text('Otro')),
    ],
    onChanged: (v) => setState(() => _genero = v),
  );

  Widget _passwordField() => AppTextField(
    label: 'Contraseña *',
    controller: _passwordCtrl,
    obscureText: _obscurePass,
    textInputAction: TextInputAction.next,
    prefixIcon: const Icon(Icons.lock_outline),
    suffixIcon: IconButton(
      icon: Icon(
        _obscurePass
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
      ),
      onPressed: () => setState(() => _obscurePass = !_obscurePass),
    ),
    validator: (v) =>
        (v == null || v.length < 8) ? 'Mínimo 8 caracteres' : null,
  );

  Widget _confirmField() => AppTextField(
    label: 'Confirmar Contraseña *',
    controller: _confirmCtrl,
    obscureText: _obscureConfirm,
    textInputAction: TextInputAction.done,
    onSubmitted: (_) => _submit(),
    prefixIcon: const Icon(Icons.lock_outline),
    suffixIcon: IconButton(
      icon: Icon(
        _obscureConfirm
            ? Icons.visibility_outlined
            : Icons.visibility_off_outlined,
      ),
      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
    ),
    validator: (v) {
      if (v == null || v.isEmpty) return 'Confirma la contraseña';
      if (v != _passwordCtrl.text) return 'No coinciden';
      return null;
    },
  );
}
