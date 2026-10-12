class ClienteDestino {
  final String nombre;
  final String apellido;
  final String cedula;
  final String telefono;
  final String direccion;
  final String? observacion;

  const ClienteDestino({
    required this.nombre,
    required this.apellido,
    required this.cedula,
    required this.telefono,
    required this.direccion,
    this.observacion,
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'apellido': apellido,
    'cedula': cedula,
    'telefono': telefono,
    'direccion': direccion,
    if (observacion != null && observacion!.isNotEmpty)
      'observacion': observacion,
  };

  factory ClienteDestino.fromJson(Map<String, dynamic> j) => ClienteDestino(
    nombre: j['nombre'] as String,
    apellido: j['apellido'] as String,
    cedula: j['cedula'] as String,
    telefono: j['telefono'] as String,
    direccion: j['direccion'] as String,
    observacion: j['observacion'] as String?,
  );
}
