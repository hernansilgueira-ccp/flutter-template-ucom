import 'lugar_disponible_model.dart';

enum EstadoReserva { activa, completada, cancelada }

class Reserva {
  final String id;
  final LugarDisponible lugar;
  final String vehiculo;
  final DateTime fechaHoraInicio;
  final DateTime fechaHoraFin;
  final double precio;
  final EstadoReserva estado;
  final String? metodoPago;
  final bool pagado;

  Reserva({
    required this.id,
    required this.lugar,
    required this.vehiculo,
    required this.fechaHoraInicio,
    required this.fechaHoraFin,
    required this.precio,
    required this.estado,
    this.metodoPago,
    this.pagado = false,
  });

  factory Reserva.fromJson(Map<String, dynamic> json, List<LugarDisponible> lugares) {
    final lugarId = json['lugarId'] ?? '';
    final lugar = lugares.firstWhere(
      (l) => l.id == lugarId,
      orElse: () => LugarDisponible(
        id: lugarId,
        nombre: 'Desconocido',
        precioPorHora: 0.0,
        ocupado: false,
      ),
    );

    return Reserva(
      id: json['id'] ?? '',
      lugar: lugar,
      vehiculo: json['vehiculo'] ?? '',
      fechaHoraInicio: DateTime.tryParse(json['fechaHoraInicio'] ?? '') ?? DateTime.now(),
      fechaHoraFin: DateTime.tryParse(json['fechaHoraFin'] ?? '') ?? DateTime.now(),
      precio: (json['precio'] ?? 0).toDouble(),
      estado: EstadoReserva.values.firstWhere(
        (e) => e.toString() == 'EstadoReserva.${json['estado']}',
        orElse: () => EstadoReserva.activa,
      ),
      metodoPago: json['metodoPago'],
      pagado: json['pagado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lugarId': lugar.id,
        'vehiculo': vehiculo,
        'fechaHoraInicio': fechaHoraInicio.toIso8601String(),
        'fechaHoraFin': fechaHoraFin.toIso8601String(),
        'precio': precio,
        'estado': estado.name,
        'metodoPago': metodoPago,
        'pagado': pagado, 
      };
  Reserva copyWith({
      String? id,
      LugarDisponible? lugar,
      String? vehiculo,
      DateTime? fechaHoraInicio,
      DateTime? fechaHoraFin,
      double? precio,
      EstadoReserva? estado,
      String? metodoPago,
      bool? pagado,
    }) {
    return Reserva(
      id: id ?? this.id,
      lugar: lugar ?? this.lugar,
      vehiculo: vehiculo ?? this.vehiculo,
      fechaHoraInicio: fechaHoraInicio ?? this.fechaHoraInicio,
      fechaHoraFin: fechaHoraFin ?? this.fechaHoraFin,
      precio: precio ?? this.precio,
      estado: estado ?? this.estado,
      metodoPago: metodoPago ?? this.metodoPago,
       pagado: pagado ?? this.pagado,
    );
  }
  double get duracionHoras =>
      fechaHoraFin.difference(fechaHoraInicio).inMinutes / 60.0;
}
