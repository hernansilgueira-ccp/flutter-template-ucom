class LugarDisponible {
  final String id;
  final String nombre;
  final double precioPorHora;

  LugarDisponible({
    required this.id,
    required this.nombre,
    required this.precioPorHora,
  });

  factory LugarDisponible.fromJson(Map<String, dynamic> json) {
    return LugarDisponible(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      precioPorHora: (json['precioPorHora'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'precioPorHora': precioPorHora,
    };
  }
}
