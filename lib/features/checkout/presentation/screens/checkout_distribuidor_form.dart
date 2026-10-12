import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../carrito/presentation/providers/cart_provider.dart';
import '../../data/models/carrito_calculado.dart';
import '../providers/checkout_providers.dart';
import '../widgets/checkout_resumen.dart';

class CheckoutDistribuidorForm extends ConsumerStatefulWidget {
  final CarritoCalculado calculo;
  final double hPad;

  const CheckoutDistribuidorForm({
    super.key,
    required this.calculo,
    required this.hPad,
  });

  @override
  ConsumerState<CheckoutDistribuidorForm> createState() =>
      CheckoutDistribuidorFormState();
}

class CheckoutDistribuidorFormState
    extends ConsumerState<CheckoutDistribuidorForm> {
  final _formKey = GlobalKey<FormState>();
  final _direccionCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  bool _aceptoTerminos = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    _direccionCtrl.text = user?.direccion ?? '';
  }

  @override
  void dispose() {
    _direccionCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_aceptoTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los términos'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    FocusScope.of(context).unfocus();

    final cartItems = ref.read(cartProvider).items;
    final pedidoId = await ref
        .read(checkoutProvider.notifier)
        .crearPedidoCredito(
          items: cartItems,
          direccionEnvio: _direccionCtrl.text.trim(),
          notas: _notasCtrl.text.trim(),
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
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: AppRadius.mdAll,
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.info, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Compra a crédito',
                        style: TextStyle(
                          color: AppColors.info,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Este pedido se cargará a tu cuenta a crédito. Tendrás 30 días '
                    'para pagarlo. Si pagas el total en los primeros 7 días, '
                    'obtienes un 7% de descuento.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            AppTextField(
              label: 'Dirección de envío *',
              hint: 'Dirección donde recibes la mercancía',
              controller: _direccionCtrl,
              prefixIcon: const Icon(Icons.home_outlined),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: AppSpacing.md),

            AppTextField(
              label: 'Notas',
              hint: 'Información adicional (opcional)',
              controller: _notasCtrl,
              maxLines: 3,
              prefixIcon: const Icon(Icons.notes),
            ),
            const SizedBox(height: AppSpacing.lg),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _aceptoTerminos,
                    onChanged: (v) =>
                        setState(() => _aceptoTerminos = v ?? false),
                    activeColor: AppColors.secondary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _aceptoTerminos = !_aceptoTerminos),
                    child: Text(
                      'Acepto los términos y condiciones de compra a crédito *',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            CheckoutResumen(
              calculo: widget.calculo,
              onConfirm: _submit,
              loading: loading,
              labelBoton: 'Crear pedido a crédito',
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
