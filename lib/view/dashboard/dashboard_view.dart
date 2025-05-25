import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finpay/controller/dashboard_controller.dart';
import 'package:finpay/model/reservas_model.dart';
import 'package:finpay/view/reservas/reserva_detalle_view.dart';

class DashboardView extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());

  DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Aquí abres una nueva vista o bottom sheet
          _mostrarFormularioReserva(context);
        },
        icon: const Icon(Icons.add),
        label: const Text("Nueva Reserva"),
      ),

      appBar: AppBar(
        title: const Text("HighLander"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.reservas.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: "Where do you want to park?",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 20),

              // Current Reservation
              if (controller.reservasActuales.isNotEmpty)
                _buildCurrentReservation(controller.reservasActuales.first),

              const SizedBox(height: 16),

              // Upcoming
              if (controller.reservasProximas.isNotEmpty)
                _buildUpcoming(controller.reservasProximas.first),

              const SizedBox(height: 16),

              // Recent
              if (controller.reservasHistorial.isNotEmpty)
                _buildRecent(controller.reservasHistorial),

              const SizedBox(height: 16),

              // Payment Methods
              _buildPaymentMethod(),

              const SizedBox(height: 16),

              // Points
              _buildPoints(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCurrentReservation(Reserva r) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.local_parking),
        title: Text(r.lugar),
        subtitle: Text(r.vehiculo ?? 'XYZ 789'),
        trailing: ElevatedButton(
          onPressed: () {
            controller.cancelarReserva(r);
            Get.snackbar("Reserva finalizada", "Tu reserva ha sido finalizada.");
            
          },

          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text("End Reservation")

        ),
      ),
    );
  }

  Widget _buildUpcoming(Reserva r) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: Text(r.lugar),
        trailing: TextButton(
          onPressed: () => Get.to(() => ReservaDetalleView(reserva: r)),
          child: const Text("Modify"),
        ),
      ),
    );
  }

  Widget _buildRecent(List<Reserva> reservas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Recent Reservations", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 8),
        ...reservas.take(2).map((r) => Card(
              child: ListTile(
                leading: const Icon(Icons.local_parking),
                title: Text(r.lugar),
                subtitle: Text("${r.inicio.day}/${r.inicio.month} - ${r.duracionHoras} h"),
                trailing: Text("\$${r.costo.toStringAsFixed(2)}"),
                onTap: () => Get.to(() => ReservaDetalleView(reserva: r)),
              ),
            )),
        TextButton(
          onPressed: () {
            // Navegar al historial completo si se desea
          },
          child: const Text("View Reservation History"),
        )
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.credit_card),
        title: const Text("Visa 1234"),
        trailing: TextButton(onPressed: () {}, child: const Text("Change")),
      ),
    );
  }

  Widget _buildPoints() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.star),
        title: const Text("520 Points"),
        trailing: TextButton(onPressed: () {}, child: const Text("View Rewards")),
      ),
    );
  }
  void _mostrarFormularioReserva(BuildContext context) {
  final lugarController = TextEditingController();
  final vehiculoController = TextEditingController();
  final duracionController = TextEditingController();
  final costoController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Nueva Reserva", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(controller: lugarController, decoration: const InputDecoration(labelText: 'Lugar')),
            TextField(controller: vehiculoController, decoration: const InputDecoration(labelText: 'Vehículo')),
            TextField(
              controller: duracionController,
              decoration: const InputDecoration(labelText: 'Duración (horas)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: costoController,
              decoration: const InputDecoration(labelText: 'Costo'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final lugar = lugarController.text;
                final vehiculo = vehiculoController.text;
                final duracion = double.tryParse(duracionController.text) ?? 1.0;
                final costo = double.tryParse(costoController.text) ?? 0.0;

                final nueva = Reserva(
                  lugar: lugar,
                  vehiculo: vehiculo,
                  inicio: DateTime.now(),
                  duracionHoras: duracion,
                  costo: costo,
                  estado: EstadoReserva.proxima,
                );

                final controller = Get.find<DashboardController>();
                controller.reservas.add(nueva);

                Get.back();
                Get.snackbar("Reserva creada", "Tu reserva fue agregada exitosamente.");
              },
              child: const Text("Guardar"),
            )
          ],
        ),
      );
    },
  );
}

}
