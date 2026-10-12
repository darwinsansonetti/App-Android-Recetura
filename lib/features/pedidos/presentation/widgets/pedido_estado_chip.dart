import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';

class PedidoEstadoChip extends StatelessWidget {
  final String texto;
  final int colorValue;

  const PedidoEstadoChip({
    super.key,
    required this.texto,
    required this.colorValue,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(colorValue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
