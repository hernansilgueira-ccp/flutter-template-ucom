import 'package:finpay/model/reserva_model.dart';

class ApiMockService {
  static Future<List<Reserva>> obtenerReservas() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simula delay

    return [
      Reserva(
        id: "1",
        lugar: "Mall Central",
        inicio: DateTime.now().subtract(const Duration(hours: 2)),
        duracionHoras: 3,
        costo: 12.0,
        estado: EstadoReserva.activa,
      ),
      Reserva(
        id: "2",
        lugar: "Estacionamiento Norte",
        inicio: DateTime.now().subtract(const Duration(hours: 5)),
        duracionHoras: 2,
        costo: 8.5,
        estado: EstadoReserva.finalizada,
      ),
    ];
  }
}
