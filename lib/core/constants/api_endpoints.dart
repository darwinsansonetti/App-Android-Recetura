class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const register = '/register';
  static const login = '/login';
  static const logout = '/logout';
  static const me = '/me';

  // Perfil
  static const perfil = '/perfil';
  static const perfilPassword = '/perfil/password';
  static const perfilDistribuidor = '/perfil/distribuidor';

  // Catálogo
  static const categorias = '/categorias';
  static const productos = '/productos';
  static const productosDestacados = '/productos/destacados';
  static const tasaActual = '/tasa-actual';
  static const contacto = '/contacto';

  // Carrito & Checkout
  static const carritoCalculator = '/carrito/calculator';
  static const checkout = '/checkout';
  static const checkoutCredito = '/checkout/credito';

  // Pedidos & Pagos
  static const pedidos = '/pedidos';
  static String pedido(int id) => '/pedidos/$id';
  static String pagos(int pedidoId) => '/pagos/$pedidoId';

  // Aliado
  static const aliadoDashboard = '/aliado/dashboard';
  static const aliadoUsuarios = '/aliado/usuarios';
  static String aliadoUsuario(int id) => '/aliado/usuarios/$id';
}
