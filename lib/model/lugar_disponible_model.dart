class LugarDisponible {
  final String id;
  final String nombre;
  final double precioPorHora;
  bool ocupado;

  LugarDisponible({
    required this.id,
    required this.nombre,
    required this.precioPorHora,
    this.ocupado = false,
  });

  factory LugarDisponible.fromJson(Map<String, dynamic> json) => LugarDisponible(
        id: json['id'] ?? json['codigoLugar'] ?? '',
        nombre: json['nombre'] ?? json['descripcionLugar'] ?? '',
        precioPorHora: (json['precioPorHora'] as num).toDouble(),
        ocupado: json['ocupado'] ?? false,
      );

  /// Serializa usando las claves del JSON de entrada/salida (para guardar en archivo)
  Map<String, dynamic> toJsonArchivo() {
    return {
      'codigoLugar': id,
      'descripcionLugar': nombre,
      'precioPorHora': precioPorHora,
      'ocupado': ocupado,
    };
  }

  /// Serializa usando las claves internas de Dart (opcional, para otros usos)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'precioPorHora': precioPorHora,
      'ocupado': ocupado,
    };
  }

  void ocupar() => ocupado = true;
  void liberar() => ocupado = false;

  LugarDisponible copyWith({
    String? id,
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LugarDisponible && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'LugarDisponible(id: $id, nombre: $nombre, precioPorHora: $precioPorHora, ocupado: $ocupado)';
}