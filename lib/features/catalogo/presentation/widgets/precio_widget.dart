import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/producto.dart';

class PrecioWidget extends StatelessWidget {
  final Producto producto;
  final double fontSize;
  final bool mostrarTachado;

  const PrecioWidget({
    super.key,
    required this.producto,
    this.fontSize = 16,
    this.mostrarTachado = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = producto.aplicaPrecioEspecial
        ? AppColors.success
        : AppColors.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (mostrarTachado &&
            producto.aplicaPrecioEspecial &&
            producto.precioEspecial != null)
          Text(
            '\$${producto.precioUnitario.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: fontSize - 4,
              color: AppColors.textTertiary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        Text(
          '\$${producto.precio.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        if (producto.aplicaPrecioEspecial &&
            producto.condicionFormateada != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              producto.condicionFormateada!,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}
