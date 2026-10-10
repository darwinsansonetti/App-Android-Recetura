// ============================================================================
// DistribuidorInfo
// ============================================================================

class DistribuidorInfo {
  final int id;
  final String? codigo;
  final String? razonSocial;
  final String? zona;
  final String? municipio;
  final String? nacionalidad;
  final bool contribuyenteEspecial;
  final String? rif;
  final String? sicm;
  final String? maestro;
  final String? observacion;
  final int? creditoDias;
  final double? limiteCredito;
  final bool activo;

  const DistribuidorInfo({
    required this.id,
    this.codigo,
    this.razonSocial,
    this.zona,
    this.municipio,
    this.nacionalidad,
    this.contribuyenteEspecial = false,
    this.rif,
    this.sicm,
    this.maestro,
    this.observacion,
    this.creditoDias,
    this.limiteCredito,
    this.activo = true,
  });

  factory DistribuidorInfo.fromJson(Map<String, dynamic> j) => DistribuidorInfo(
    id: (j['id'] ?? 0) as int,
    codigo: j['codigo'] as String?,
    razonSocial: j['razon_social'] as String?,
    zona: j['zona'] as String?,
    municipio: j['municipio'] as String?,
    nacionalidad: j['nacionalidad'] as String?,
    contribuyenteEspecial: (j['contribuyente_especial'] ?? false) as bool,
    rif: j['rif'] as String?,
    sicm: j['sicm'] as String?,
    maestro: j['maestro'] as String?,
    observacion: j['observacion'] as String?,
    creditoDias: j['credito_dias'] as int?,
    limiteCredito: j['limite_credito'] != null
        ? (j['limite_credito'] as num).toDouble()
        : null,
    activo: (j['activo'] ?? true) as bool,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'codigo': codigo,
    'razon_social': razonSocial,
    'zona': zona,
    'municipio': municipio,
    'nacionalidad': nacionalidad,
    'contribuyente_especial': contribuyenteEspecial,
    'rif': rif,
    'sicm': sicm,
    'maestro': maestro,
    'observacion': observacion,
    'credito_dias': creditoDias,
    'limite_credito': limiteCredito,
    'activo': activo,
  };
}

// ============================================================================
// User
// ============================================================================

class User {
  final int id;
  final String name;
  final String? apellido;
  final String email;
  final String? telefono;
  final String? celular;
  final String? documentoIdentidad;
  final String? fechaNacimiento;
  final String? genero;
  final String? direccion;
  final String? ciudad;
  final String? estadoProvincia;
  final String? pais;
  final String? codigoPostal;
  final String estadoCuenta;
  final String? tipoUsuario;

  /// Rol: viene como objeto `{id, slug, nombre}` desde la API
  final String roleSlug;
  final String roleNombre;

  /// Info de perfil
  final bool perfilCompleto;
  final Map<String, dynamic>? camposFaltantes;

  /// Info adicional del distribuidor (solo si roleSlug == 'distribuidor')
  final DistribuidorInfo? distribuidor;

  final DateTime? createdAt;

  const User({
    required this.id,
    required this.name,
    this.apellido,
    required this.email,
    this.telefono,
    this.celular,
    this.documentoIdentidad,
    this.fechaNacimiento,
    this.genero,
    this.direccion,
    this.ciudad,
    this.estadoProvincia,
    this.pais,
    this.codigoPostal,
    required this.estadoCuenta,
    this.tipoUsuario,
    required this.roleSlug,
    required this.roleNombre,
    required this.perfilCompleto,
    this.camposFaltantes,
    this.distribuidor,
    this.createdAt,
  });

  /// Alias por compatibilidad con código existente
  String get rol => roleSlug;

  String get nombreCompleto =>
      apellido == null || apellido!.isEmpty ? name : '$name $apellido';

  // Getters de rol
  bool get esDistribuidor => roleSlug == 'distribuidor';
  bool get esNegocio => roleSlug == 'negocio';
  bool get esAliado => roleSlug == 'aliado';
  bool get esProfesional => roleSlug == 'profesional';
  bool get esConsumidor => roleSlug == 'consumidor';

  /// ¿El distribuidor ya completó su razón social?
  bool get tieneInfoDistribuidor =>
      distribuidor != null && (distribuidor!.razonSocial?.isNotEmpty ?? false);

  factory User.fromJson(Map<String, dynamic> j) {
    // El rol viene como objeto anidado
    final role = j['role'] as Map<String, dynamic>?;
    final roleSlug = (role?['slug'] ?? 'consumidor') as String;
    final roleNombre = (role?['nombre'] ?? 'Consumidor') as String;

    return User(
      id: j['id'] as int,
      name: (j['name'] ?? '') as String,
      apellido: j['apellido'] as String?,
      email: (j['email'] ?? '') as String,
      telefono: j['telefono'] as String?,
      celular: j['celular'] as String?,
      documentoIdentidad: j['documento_identidad'] as String?,
      fechaNacimiento: j['fecha_nacimiento'] as String?,
      genero: j['genero'] as String?,
      direccion: j['direccion'] as String?,
      ciudad: j['ciudad'] as String?,
      estadoProvincia: j['estado_provincia'] as String?,
      pais: j['pais'] as String?,
      codigoPostal: j['codigo_postal'] as String?,
      estadoCuenta: (j['estado_cuenta'] ?? 'activo') as String,
      tipoUsuario: j['tipo_usuario'] as String?,
      roleSlug: roleSlug,
      roleNombre: roleNombre,
      perfilCompleto: (j['perfil_completo'] ?? false) as bool,
      camposFaltantes: _parseCamposFaltantes(j['campos_faltantes']),
      distribuidor: j['distribuidor'] != null
          ? DistribuidorInfo.fromJson(
              Map<String, dynamic>.from(j['distribuidor'] as Map),
            )
          : null,
      createdAt: j['created_at'] != null
          ? DateTime.tryParse(j['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'apellido': apellido,
    'email': email,
    'telefono': telefono,
    'celular': celular,
    'documento_identidad': documentoIdentidad,
    'fecha_nacimiento': fechaNacimiento,
    'genero': genero,
    'direccion': direccion,
    'ciudad': ciudad,
    'estado_provincia': estadoProvincia,
    'pais': pais,
    'codigo_postal': codigoPostal,
    'estado_cuenta': estadoCuenta,
    'tipo_usuario': tipoUsuario,
    'role': {'slug': roleSlug, 'nombre': roleNombre},
    'perfil_completo': perfilCompleto,
    'campos_faltantes': camposFaltantes,
    'distribuidor': distribuidor?.toJson(),
    'created_at': createdAt?.toIso8601String(),
  };

  /// `campos_faltantes` puede venir como:
  /// - Lista vacía `[]` → significa "no falta nada"
  /// - Objeto `{campo: label, ...}` → hay campos pendientes
  /// - null → por si acaso
  static Map<String, dynamic>? _parseCamposFaltantes(dynamic raw) {
    if (raw == null) return null;
    if (raw is List) {
      return null; // lista vacía o inesperada → sin faltantes
    }
    if (raw is Map) {
      if (raw.isEmpty) return null;
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }
}
