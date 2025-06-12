class Usuario {
  final String nombre;
  final String avatar; // <- asegúrate de tener esta propiedad
  final List<String> vehiculos;

  Usuario({
    required this.nombre,
    required this.avatar,
    required this.vehiculos,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      nombre: json['nombre'],
      avatar: json['avatar'] ?? '',
      vehiculos: List<String>.from(json['vehiculos'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'avatar': avatar,
      'vehiculos': vehiculos,
    };
  }
}
