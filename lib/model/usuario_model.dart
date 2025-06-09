class Usuario {
  final String nombre;
  final String avatar; // <- asegúrate de tener esta propiedad

  Usuario({
    required this.nombre,
    required this.avatar,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      nombre: json['nombre'],
      avatar: json['avatar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'avatar': avatar,
    };
  }
}
