class AppBancos {
  AppBancos._();

  /// Lista de bancos venezolanos (basada en la web)
  static const List<String> lista = [
    'Banco de Venezuela (0102)',
    'Banco Bicentenario (0175)',
    'Banco del Tesoro (0163)',
    'Banco Agrícola de Venezuela (0166)',
    'Banco Nacional de Crédito (0191)',
    'Banco de la Fuerza Armada Nacional (0177)',
    'Banco de la Mujer (0146)',
    'Banco del Pueblo Soberano (0146)',
    'BANDES (0124)',
    'Banesco (0134)',
    'Banco Mercantil (0105)',
    'BBVA Provincial (0108)',
    'Banco Exterior (0115)',
    'Banco Caroní (0128)',
    'Bancamiga (0172)',
    'Banco Activo (0137)',
    'Banco Plaza (0138)',
    'Banco Fondo Común (0151)',
    '100% Banco (0156)',
    'Banco Sofitasa (0168)',
    'Bancrecer (0169)',
    'Banco Venezolano de Crédito (0104)',
    'Banco Bancaribe (0114)',
    'Banco del Sur (0127)',
    'Banco Banplus (0174)',
    'Banco Banfortaleza (0176)',
    'Banco Mi Casa (0169)',
    'Banco Pago Móvil (0141)',
    'Banco Citi Venezuela (0110)',
    'Banco Federal (0184)',
    'Banco Nobel (0164)',
    'Banco Internacional de Desarrollo (0171)',
    'Banco Oriente (0163)',
    'Banco Confederado (0122)',
    'Banco Italo Venezolano (0112)',
    'Banco Real (0136)',
    'Banco Canarias (0118)',
    'Banco Unión (0135)',
    'Banco Guayana (0129)',
    'Banco Latino (0125)',
    'Banco Profesional (0121)',
    'Banco Amazonas (0130)',
    'Banco Barinas (0123)',
    'Banco de los Trabajadores (0141)',
  ];

  /// Banco destino por defecto (el que aparece en la web)
  static const String bancoDestinoDefault = 'Bancamiga (0172)';

  /// Datos bancarios de MR. Recetura (los que se muestran en el checkout)
  // ============================================================
  // Datos de Pago Móvil de MR. Recetura (los que se muestran)
  // ============================================================
  static const String pagoMovilTelefono = '0424-6298552';
  static const String pagoMovilBanco = 'Bancamiga (0172)';
  static const String pagoMovilDocumento = 'J-50443556-2';

  // Datos de Transferencia (por si acaso)
  static const String transferenciaBanco = 'Bancamiga';
  static const String transferenciaCuenta = '0172-0702-49-7025859153';
  static const String transferenciaTipoCuenta = 'Corriente';
  static const String transferenciaTitular = 'Mr Casa de Recetura';
}
