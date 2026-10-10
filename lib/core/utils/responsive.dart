import 'package:flutter/material.dart';

/// Breakpoints basados en Material Design 3
/// https://m3.material.io/foundations/layout/understanding-layout/overview
enum DeviceType { mobile, tablet, desktop }

class Responsive {
  Responsive._();

  static const double mobileMax = 600;
  static const double tabletMax = 1024;

  static DeviceType of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobileMax) return DeviceType.mobile;
    if (width < tabletMax) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  static bool isMobile(BuildContext ctx) => of(ctx) == DeviceType.mobile;
  static bool isTablet(BuildContext ctx) => of(ctx) == DeviceType.tablet;
  static bool isDesktop(BuildContext ctx) => of(ctx) == DeviceType.desktop;

  /// Número de columnas para grids según el tipo de dispositivo
  static int gridColumns(
    BuildContext ctx, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 5,
  }) {
    switch (of(ctx)) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
    }
  }

  /// Ancho máximo para contenido (evita que en pantallas gigantes
  /// el contenido se estire demasiado)
  static double maxContentWidth(BuildContext ctx) {
    switch (of(ctx)) {
      case DeviceType.mobile:
        return double.infinity;
      case DeviceType.tablet:
        return 720;
      case DeviceType.desktop:
        return 1000;
    }
  }

  /// Padding lateral según dispositivo
  static double horizontalPadding(BuildContext ctx) {
    switch (of(ctx)) {
      case DeviceType.mobile:
        return 16;
      case DeviceType.tablet:
        return 24;
      case DeviceType.desktop:
        return 32;
    }
  }
}

/// Widget que centra el contenido y limita su ancho máximo
/// Úsalo en pantallas para que en tablets no se estire todo
class CenteredConstrained extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const CenteredConstrained({super.key, required this.child, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? Responsive.maxContentWidth(context),
        ),
        child: child,
      ),
    );
  }
}
