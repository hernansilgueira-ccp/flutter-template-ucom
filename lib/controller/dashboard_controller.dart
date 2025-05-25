import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:finpay/model/reservas_model.dart' show Reserva, EstadoReserva;

class DashboardController extends GetxController {
  final RxList<Reserva> reservas = <Reserva>[].obs;

  List<Reserva> get reservasActuales => reservas
      .where((r) => r.estado == EstadoReserva.actual)
      .toList()
    ..sort((a, b) => a.inicio.compareTo(b.inicio));

  List<Reserva> get reservasProximas => reservas
      .where((r) => r.estado == EstadoReserva.proxima)
      .toList()
    ..sort((a, b) => a.inicio.compareTo(b.inicio));

  List<Reserva> get reservasHistorial => reservas
      .where((r) => r.estado == EstadoReserva.historial)
      .toList()
    ..sort((a, b) => b.inicio.compareTo(a.inicio)); // más recientes primero

  @override
  void onInit() {
    super.onInit();
    cargarMockReservas();
  }

  void cargarMockReservas() async {
    final String jsonString = await rootBundle.loadString('assets/data/mock_reservas.json');
    final List<dynamic> data = json.decode(jsonString);
    reservas.clear();
    reservas.addAll(data.map((e) => Reserva.fromJson(e)).toList());
  }

  void repetirReserva(Reserva reserva) {
    final nueva = Reserva(
      lugar: reserva.lugar,
      vehiculo: reserva.vehiculo,
      inicio: DateTime.now().add(const Duration(minutes: 5)),
      duracionHoras: reserva.duracionHoras,
      costo: reserva.costo,
      estado: EstadoReserva.proxima,
    );

    reservas.add(nueva);
  }
  void cancelarReserva(Reserva reserva) {
  final index = reservas.indexOf(reserva);
  if (index != -1) {
    reservas[index] = reserva.copyWith(estado: EstadoReserva.historial);
  }
}

}
