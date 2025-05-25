enum EstadoReserva { actual, proxima, historial }

class Reserva {
  final String lugar;
  final String vehiculo;
  final DateTime inicio;
  final double duracionHoras;
  final double costo;
  final EstadoReserva estado;

  Reserva({
    required this.lugar,
    required this.vehiculo,
    required this.inicio,
    required this.duracionHoras,
    required this.costo,
    required this.estado,
  });

  Reserva copyWith({
    String? lugar,
    String? vehiculo,
    DateTime? inicio,
    double? duracionHoras,
    double? costo,
    EstadoReserva? estado,
  }) {
    return Reserva(
      lugar: lugar ?? this.lugar,
      vehiculo: vehiculo ?? this.vehiculo,
      inicio: inicio ?? this.inicio,
      duracionHoras: duracionHoras ?? this.duracionHoras,
      costo: costo ?? this.costo,
      estado: estado ?? this.estado,
    );
  }

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      lugar: json['lugar'],
      vehiculo: json['vehiculo'],
      inicio: DateTime.parse(json['inicio']),
      duracionHoras: (json['duracionHoras'] as num).toDouble(),
      costo: (json['costo'] as num).toDouble(),
      estado: EstadoReserva.values.firstWhere(
        (e) => e.name == json['estado'],
        orElse: () => EstadoReserva.historial,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'lugar': lugar,
    'vehiculo': vehiculo,
    'inicio': inicio.toIso8601String(),
    'duracionHoras': duracionHoras,
    'costo': costo,
    'estado': estado.name,
  };
}
