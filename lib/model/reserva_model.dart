class Reserva {
  final String id;
  final String lugar;
  final DateTime inicio;
  final int duracionHoras;
  final double costo;
  final EstadoReserva estado;

  Reserva({
    required this.id,
    required this.lugar,
    required this.inicio,
    required this.duracionHoras,
    required this.costo,
    required this.estado,
  });
}

enum EstadoReserva {
  activa,
  cancelada,
  finalizada,
}

extension EstadoReservaExtension on EstadoReserva {
  String get nombre {
    switch (this) {
      case EstadoReserva.activa:
        return 'Activa';
      case EstadoReserva.cancelada:
        return 'Cancelada';
      case EstadoReserva.finalizada:
        return 'Finalizada';
    }
  }
}
