import 'package:flutter/material.dart';

enum EstadoReserva { activa, completada, cancelada }

class Reserva {
  final int id;
  final String lugar;
  final String vehiculo;
  final DateTime inicio;
  final double duracionHoras;
  final double costo;
  final EstadoReserva estado;
  bool pagado;

  DateTime get fin => inicio.add(Duration(hours: duracionHoras.toInt()));

  Reserva({
    required this.id,
    required this.lugar,
    required this.vehiculo,
    required this.inicio,
    required this.duracionHoras,
    required this.costo,
    required this.estado,
    this.pagado = false,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
  print('Parsing reserva: $json');
  return Reserva(
    id: json['id'],
    lugar: json['lugar'],
    vehiculo: json['vehiculo'],
    inicio: DateTime.parse(json['inicio']),
    duracionHoras: (json['duracionHoras'] ?? 1).toDouble(),
    costo: (json['costo'] ?? 0).toDouble(),
    estado: EstadoReserva.values.firstWhere(
      (e) => e.name == json['estado'],
      orElse: () => EstadoReserva.activa,
    ),
    pagado: json['pagado'] ?? false,
  );
}


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lugar': lugar,
      'vehiculo': vehiculo,
      'inicio': inicio.toIso8601String(),
      'duracionHoras': duracionHoras,
      'costo': costo,
      'estado': estado.name,
      'pagado': pagado,
    };
  }

  Reserva copyWith({
    String? lugar,
    String? vehiculo,
    DateTime? inicio,
    double? duracionHoras,
    double? costo,
    EstadoReserva? estado,
    bool? pagado,
  }) {
    return Reserva(
      id: id,
      lugar: lugar ?? this.lugar,
      vehiculo: vehiculo ?? this.vehiculo,
      inicio: inicio ?? this.inicio,
      duracionHoras: duracionHoras ?? this.duracionHoras,
      costo: costo ?? this.costo,
      estado: estado ?? this.estado,
      pagado: pagado ?? this.pagado,
    );
  }
}
