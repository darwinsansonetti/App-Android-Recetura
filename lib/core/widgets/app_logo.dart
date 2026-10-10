import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double height;
  final BoxFit fit;

  const AppLogo({super.key, this.height = 80, this.fit = BoxFit.contain});

  /// Constructor para el ícono blanco sobre fondo de color (splash)
  const AppLogo.white({super.key, this.height = 80}) : fit = BoxFit.contain;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: height,
      fit: fit,
      errorBuilder: (context, error, stack) {
        // Fallback si el asset falla
        return Icon(
          Icons.local_pharmacy,
          size: height,
          color: Theme.of(context).colorScheme.primary,
        );
      },
    );
  }
}
