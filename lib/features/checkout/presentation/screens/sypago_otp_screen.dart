import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/sypago_providers.dart';

class SypagoOtpScreen extends ConsumerStatefulWidget {
  final int pedidoId;
  const SypagoOtpScreen({super.key, required this.pedidoId});

  @override
  ConsumerState<SypagoOtpScreen> createState() => _SypagoOtpScreenState();
}

class _SypagoOtpScreenState extends ConsumerState<SypagoOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      _nombreCtrl.text = user.nombreCompleto;
    }
  }

  @override
  void dispose() {
    _otpCtrl.dispose();
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final ok = await ref
        .read(sypagoProvider.notifier)
        .cobrar(
          otp: _otpCtrl.text.trim(),
          clienteNombre: _nombreCtrl.text.trim(),
        );

    if (!mounted) return;
    if (ok) {
      context.pushReplacement('/sypago/${widget.pedidoId}/espera');
    } else {
      final err = ref.read(sypagoProvider).error ?? 'Error al cobrar';
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
      appBar: AppBar(title: const Text('Verificar código')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.08),
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.success,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Hemos enviado un código a tu teléfono. Ingrésalo para confirmar el pago.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                AppTextField(
                  label: 'Código OTP *',
                  hint: '12345678',
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.lock_outline),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (v.length < 6) return 'Mínimo 6 dígitos';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  label: 'Nombre del titular *',
                  controller: _nombreCtrl,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: AppSpacing.xl),

                AppButton(
                  label: 'Confirmar pago',
                  icon: Icons.check,
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
