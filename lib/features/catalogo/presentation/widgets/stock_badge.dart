import 'package:flutter/material.dart';
import '../../../../core/theme/app_radius.dart';
import '../../data/models/producto.dart';

class StockBadge extends StatelessWidget {
  final Producto producto;
  const StockBadge({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    final color = Color(producto.stockColorValue);
    final texto = producto.stockTexto ?? 'Stock desconocido';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            texto,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
