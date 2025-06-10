import 'package:flutter/foundation.dart';

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

  factory LugarDisponible.fromJson(Map<String, dynamic> json) {
    return LugarDisponible(
      id: json['id'] ??'',
      nombre: json['nombre'] ?? 'Desconocido',
      precioPorHora: (json['precioPorHora'] ?? 0).toDouble(),
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
      other is LugarDisponible &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'LugarDisponible(id: $id, nombre: $nombre, precioPorHora: $precioPorHora, ocupado: $ocupado)';

      
}
