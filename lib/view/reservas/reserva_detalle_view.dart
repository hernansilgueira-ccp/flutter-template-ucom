import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finpay/controller/dashboard_controller.dart';
import 'package:finpay/model/reservas_model.dart';

class ReservaDetalleView extends StatelessWidget {
  final Reserva reserva;
  final DashboardController controller = Get.find<DashboardController>();

  ReservaDetalleView({super.key, required this.reserva});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Reserva'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lugar: ${reserva.lugar.nombre}', style: _tituloStyle()),
            SizedBox(height: 8),
            Text('Vehículo: ${reserva.vehiculo}', style: _textoStyle()),
            SizedBox(height: 8),
            Text('Inicio: ${reserva.fechaHoraInicio}', style: _textoStyle()),
            SizedBox(height: 8),
            Text('Duración (h): ${reserva.duracionHoras}', style: _textoStyle()),
            SizedBox(height: 8),
            Text('Costo: \$${reserva.precio.toStringAsFixed(2)}', style: _textoStyle()),
            SizedBox(height: 8),
            Text('Estado: ${reserva.estado.name}', style: _textoStyle()),
            SizedBox(height: 24),

            if (reserva.estado == EstadoReserva.activa)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _marcarComoCompletada();
                    Get.back();
                  },
                  child: Text('Marcar como Completada'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  TextStyle _tituloStyle() => TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  TextStyle _textoStyle() => TextStyle(fontSize: 16);

  void _marcarComoCompletada() {
    // Crear una copia con estado completado
    final reservaActualizada = reserva.copyWith(estado: EstadoReserva.completada);

    // Reemplazar la reserva en la lista
    int index = controller.reservas.indexWhere((r) => r.id == reserva.id);
    if (index != -1) {
      controller.reservas[index] = reservaActualizada;
    }

    // Liberar el lugar
    controller.liberarLugar(reserva.lugar.id);

    Get.snackbar(
      'Reserva',
      'Reserva marcada como completada.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
    );
  }
}
