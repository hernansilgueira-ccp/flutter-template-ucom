import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/dashboard_controller.dart';
import '../../config/textstyle.dart';
import '../../model/reservas_model.dart'; // Asegúrate de importar esto

class ReservaDetalleView extends StatelessWidget {
  final Reserva reserva;

  const ReservaDetalleView({super.key, required this.reserva});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalle de Reserva"),
        backgroundColor: HexColor(AppTheme.primaryColorString!),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Lugar: ${reserva.lugar}", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text("Vehículo: ${reserva.vehiculo}", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text("Inicio: ${reserva.inicio}", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text("Duración: ${reserva.duracionHoras} horas", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text("Costo: \$${reserva.costo}", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text("Estado: ${reserva.estado.name}", style: const TextStyle(fontSize: 18)),

                const SizedBox(height: 24),

                if (reserva.estado == EstadoReserva.proxima) ...[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.cancel),
                    label: const Text("Cancelar Reserva"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      controller.cancelarReserva(reserva);
                      Get.back();
                      Get.snackbar("Reserva cancelada", "Tu reserva ha sido cancelada.");
                    },
                  )
                ] else if (reserva.estado == EstadoReserva.historial) ...[
                  ElevatedButton.icon(
                    icon: const Icon(Icons.repeat),
                    label: const Text("Repetir Reserva"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HexColor(AppTheme.primaryColorString!),
                    ),
                    onPressed: () {
                      //controller.repetirReserva(reserva);
                      Get.back();
                      Get.snackbar("Reserva creada", "Tu nueva reserva fue agendada.");
                    },
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
