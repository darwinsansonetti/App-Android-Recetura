import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/aliado/presentation/screens/aliado_shell_screen.dart';
import 'features/aliado/presentation/screens/crear_distribuidor_screen.dart';
import 'features/aliado/presentation/screens/distribuidor_detalle_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/catalogo/presentation/screens/catalogo_shell_screen.dart';
import 'features/catalogo/presentation/screens/producto_detalle_screen.dart';
import 'features/catalogo/presentation/screens/productos_list_screen.dart';
import 'features/catalogo/presentation/screens/search_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/perfil/presentation/screens/cambiar_password_screen.dart';
import 'features/perfil/presentation/screens/editar_perfil_screen.dart';
import 'features/perfil/presentation/screens/perfil_distribuidor_screen.dart';
import 'features/perfil/presentation/screens/perfil_screen.dart';
import 'features/checkout/presentation/screens/checkout_screen.dart';
import 'features/checkout/presentation/screens/pedido_confirmado_screen.dart';
import 'features/pedidos/presentation/screens/pedidos_list_screen.dart';
import 'features/pedidos/presentation/screens/pedido_detalle_screen.dart';
import 'features/pedidos/presentation/screens/reportar_pago_screen.dart';

final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Auth
    GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
    GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),

    // Catálogo
    GoRoute(path: '/catalogo', builder: (_, _) => const CatalogoShellScreen()),
    GoRoute(
      path: '/catalogo/productos',
      builder: (_, _) => const ProductosListScreen(),
    ),
    GoRoute(
      path: '/catalogo/categoria/:id',
      builder: (_, state) => ProductosListScreen(
        categoriaId: int.parse(state.pathParameters['id']!),
        titulo: 'Categoría',
      ),
    ),
    GoRoute(path: '/catalogo/buscar', builder: (_, _) => const SearchScreen()),
    GoRoute(
      path: '/catalogo/producto/:slug',
      builder: (_, state) =>
          ProductoDetalleScreen(idOrSlug: state.pathParameters['slug']!),
    ),

    // Mi Perfil
    GoRoute(path: '/perfil', builder: (_, _) => const PerfilScreen()),
    GoRoute(
      path: '/perfil/editar',
      builder: (_, _) => const EditarPerfilScreen(),
    ),
    GoRoute(
      path: '/perfil/password',
      builder: (_, _) => const CambiarPasswordScreen(),
    ),
    GoRoute(
      path: '/perfil/distribuidor',
      builder: (_, _) => const PerfilDistribuidorScreen(),
    ),

    // Panel del Aliado
    GoRoute(path: '/aliado', builder: (_, _) => const AliadoShellScreen()),
    GoRoute(
      path: '/aliado/usuarios/crear',
      builder: (_, _) => const CrearDistribuidorScreen(),
    ),
    GoRoute(
      path: '/aliado/usuarios/:id',
      builder: (_, state) =>
          DistribuidorDetalleScreen(id: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/aliado/pedidos/:id',
      builder: (_, state) => PedidoDetalleScreen(
        pedidoId: int.parse(state.pathParameters['id']!),
        esVistaAliado: true,
      ),
    ),
    // Checkout
    GoRoute(path: '/checkout', builder: (_, _) => const CheckoutScreen()),
    GoRoute(
      path: '/pedido-confirmado/:id',
      builder: (_, state) => PedidoConfirmadoScreen(
        pedidoId: int.parse(state.pathParameters['id']!),
      ),
    ),
    // Placeholder de pedidos (lo hacemos después)
    GoRoute(path: '/pedidos', builder: (_, _) => const PedidosListScreen()),
    GoRoute(
      path: '/pedidos/:id/reportar-pago',
      builder: (_, state) =>
          ReportarPagoScreen(pedidoId: int.parse(state.pathParameters['id']!)),
    ),
    GoRoute(
      path: '/pedidos/:id',
      builder: (_, state) =>
          PedidoDetalleScreen(pedidoId: int.parse(state.pathParameters['id']!)),
    ),
  ],
);

class MrReceturaApp extends ConsumerWidget {
  const MrReceturaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'MR. Recetura',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: _router,
          locale: const Locale('es', 'VE'),
          supportedLocales: const [Locale('es', 'VE'), Locale('en', 'US')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}
