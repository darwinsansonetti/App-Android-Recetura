class Tasa {
  final int id;
  final double valor;
  final String fecha;

  const Tasa({required this.id, required this.valor, required this.fecha});

  factory Tasa.fromJson(Map<String, dynamic> j) => Tasa(
    id: (j['id'] ?? 0) as int,
    valor: ((j['valor'] ?? 0) as num).toDouble(),
    fecha: (j['fecha'] ?? '') as String,
  );
}
