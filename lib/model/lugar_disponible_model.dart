class LugarDisponible {
  final int id;
  final String nombre;
  final double precioPorHora;
  bool ocupado;

  LugarDisponible({
    required this.id,
    required this.nombre,
    required this.precioPorHora,
    this.ocupado = false,
  });

  factory LugarDisponible.fromJson(Map<String, dynamic> json) {
    return LugarDisponible(
      id: json['id'],
      nombre: json['nombre'],
      precioPorHora: (json['precioPorHora'] as num).toDouble(),
      ocupado: json['ocupado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'precioPorHora': precioPorHora,
      'ocupado': ocupado,
    };
  }
}
