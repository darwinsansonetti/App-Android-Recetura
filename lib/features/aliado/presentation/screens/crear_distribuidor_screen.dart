import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/aliado_providers.dart';

class CrearDistribuidorScreen extends ConsumerStatefulWidget {
  const CrearDistribuidorScreen({super.key});

  @override
  ConsumerState<CrearDistribuidorScreen> createState() =>
      _CrearDistribuidorScreenState();
}

class _CrearDistribuidorScreenState
    extends ConsumerState<CrearDistribuidorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _apellidoCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      final result = await ref
          .read(aliadoRepositoryProvider)
          .crearDistribuidor(
            name: _nameCtrl.text.trim(),
            apellido: _apellidoCtrl.text.trim().isEmpty
                ? null
                : _apellidoCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
          );

      if (!mounted) return;
      ref.invalidate(distribuidoresListProvider);

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Distribuidor creado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Usuario:', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 2),
              Text(
                result.user.email,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Contraseña temporal:',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppRadius.smAll,
                ),
                child: SelectableText(
                  result.passwordGenerado,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: AppRadius.smAll,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Compártela con el distribuidor. No se volverá a mostrar completa.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
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
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );

      if (mounted) context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);

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
              context.go('/aliado');
            }
          },
        ),
      ),
      body: SafeArea(
        top: false,
        child: CenteredConstrained(
          maxWidth: 520,
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: hPad,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card blanca con sombra (igual que login y register)
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
                        const Center(child: AppLogo(height: 90)),
                        const SizedBox(height: AppSpacing.xl),

                        Text(
                          'Nuevo Distribuidor',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Se generará una contraseña temporal automáticamente.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.xxl),

                        AppTextField(
                          label: 'Nombre *',
                          controller: _nameCtrl,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.person_outline),
                          validator: (v) => (v == null || v.trim().length < 2)
                              ? 'Mínimo 2 caracteres'
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        AppTextField(
                          label: 'Apellido',
                          controller: _apellidoCtrl,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        AppTextField(
                          label: 'Correo Electrónico *',
                          hint: 'distribuidor@ejemplo.com',
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
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
                        const SizedBox(height: AppSpacing.xl),

                        AppButton(
                          label: 'Crear Distribuidor',
                          icon: Icons.person_add_alt_1,
                          loading: _loading,
                          onPressed: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
