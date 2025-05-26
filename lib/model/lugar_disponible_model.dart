class LugarDisponible {
  final int id;
  final String nombre;
  final double precioPorHora;
  bool ocupado;

  LugarDisponible({
    required this.id,
    required this.nombre,
    required this.precioPorHora,
    this.ocupado = false, // por defecto está disponible
  });

  factory LugarDisponible.fromJson(Map<String, dynamic> json) {
  return LugarDisponible(
    id: json['id'],
    nombre: json['nombre'],
    precioPorHora: (json['precioHora'] as num).toDouble(),
    ocupado: (json['ocupado'] is bool) ? json['ocupado'] : false,
  );
}


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'precioHora': precioPorHora,
      'ocupado': ocupado,
    };
  }

  LugarDisponible copyWith({
    int? id,
    String? nombre,
    double? precioPorHora,
    bool? ocupado,
  }) {
    return LugarDisponible(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precioPorHora: precioPorHora ?? this.precioPorHora,
      ocupado: ocupado ?? this.ocupado,
    );
  }
}
