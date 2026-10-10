import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_bootstrap);
  }

  Future<void> _bootstrap() async {
    debugPrint('SPLASH: iniciando bootstrap');
    bool ok = false;
    try {
      ok = await ref
          .read(authProvider.notifier)
          .bootstrap()
          .timeout(const Duration(seconds: 8));
      debugPrint('SPLASH: bootstrap ok=$ok');
    } catch (e) {
      debugPrint('SPLASH: bootstrap falló: $e');
    }

    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    debugPrint('SPLASH: navegando a ${ok ? "/home" : "/login"}');
    context.go(ok ? '/home' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Spacer(),
              // Logo real (con fondo blanco, no necesita versión blanca)
              const AppLogo(height: 60),
              const SizedBox(height: 32),
              // Indicador de carga
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: AppColors.secondary,
                  strokeWidth: 3,
                ),
              ),
              const Spacer(),
              // Versión abajo
              Text(
                'v1.0.0',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
