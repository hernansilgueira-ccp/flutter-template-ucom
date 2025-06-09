import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/dashboard_controller.dart'; // Importa DashboardController
import '../../model/reservas_model.dart';
import '../../utils/utiles.dart';

class HomeView extends StatelessWidget {
  final DashboardController dashboardController;

  HomeView({super.key, required this.dashboardController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: Obx(() {
        final reservas = dashboardController.reservas;
        final pagos = dashboardController.pagos;

        if (reservas.isEmpty) {
          return const Center(child: Text("No hay reservas registradas"));
        }

        return ListView.builder(
          itemCount: reservas.length,
          itemBuilder: (context, index) {
            final reserva = reservas[index];
            final pago = pagos.firstWhereOrNull((p) => p.reservaId == reserva.id);

            final lugarNombre = reserva.lugar is String
                ? reserva.lugar
                : (reserva.lugar as dynamic).nombre ?? 'Lugar desconocido';

            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(lugarNombre),
                subtitle: Text(
                  "${UtilesApp.formatearFechaDdMMAaaa(reserva.inicio)} a ${UtilesApp.formatearFechaDdMMAaaa(reserva.fin)}\n"
                  "Costo: \$${reserva.costo} • Estado: ${reserva.estado.name}",
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      reserva.pagado ? Icons.check_circle : Icons.payment,
                      color: reserva.pagado ? Colors.green : Colors.orange,
                    ),
                    if (!reserva.pagado)
                      TextButton(
                        onPressed: () async {
                          await dashboardController.registrarPago(reserva, 'Tarjeta');
                          Get.snackbar("Pago registrado", "Reserva pagada correctamente");
                        },
                        child: const Text("Pagar"),
                      )
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
