class Pago {
  final int id;
  final String reservaId;
  final String metodo;
  final DateTime fecha;
  final double monto;

  Pago({
    required this.id,
    required this.reservaId,
    required this.metodo,
    required this.fecha,
    required this.monto,
  });

  factory Pago.fromJson(Map<String, dynamic> json) {
    return Pago(
      id: json['id'],
      reservaId: json['reservaId'],
      metodo: json['metodo'],
      fecha: DateTime.parse(json['fecha']),
      monto: (json['monto'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservaId': reservaId,
      'metodo': metodo,
      'fecha': fecha.toIso8601String(),
      'monto': monto,
    };
  }
}
