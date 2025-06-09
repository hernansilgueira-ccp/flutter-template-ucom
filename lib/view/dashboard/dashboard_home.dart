import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finpay/controller/dashboard_controller.dart';
import 'package:finpay/model/lugar_disponible_model.dart';
import 'package:finpay/model/reservas_model.dart';
import 'package:finpay/widgets/reservas_proximas_widget.dart';


class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  final DashboardController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text("Hola, ${controller.usuario.value.nombre}")),
        actions: [
          CircleAvatar(
            backgroundImage: AssetImage(controller.usuario.value.avatarUrl),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text("Reservas actuales", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...controller.reservasActuales.map((r) => _buildReservaCard(r, Colors.green)),

            const SizedBox(height: 20),
            const Text("Próximas reservas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...controller.reservasProximas.map((r) => _buildReservaCard(r, Colors.blue)),

            const SizedBox(height: 20),
            const Text("Historial", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...controller.reservasHistorial.map((r) => _buildReservaCard(r, Colors.grey)),

            const SizedBox(height: 20),
            const ReservasProximasWidget(), // si quieres usar el widget adicional
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioNuevaReserva(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReservaCard(Reserva reserva, Color color) {
    final lugar = controller.lugaresDisponibles.firstWhere(
      (l) => l.descripcionLugar.trim().toLowerCase() == reserva.lugar.trim().toLowerCase(),
      orElse: () => LugarDisponible(
        codigoPiso: "N/A",
        codigoLugar: "N/A",
        descripcionLugar: reserva.lugar,
        precioPorHora: 0.0,
      ),
    );

    final montoTotal = lugar.precioPorHora * reserva.duracionHoras;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.local_parking, color: color),
        title: Text(reserva.lugar),
        subtitle: Text(
          "Vehículo: ${reserva.vehiculo}\n"
          "Inicio: ${reserva.inicio}\n"
          "Duración: ${reserva.duracionHoras}h\n"
          "Monto a pagar: \$${reserva.costo.toStringAsFixed(2)}",
        ),
        trailing: reserva.estado != EstadoReserva.historial
            ? IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: () async {
                  await controller.cancelarReserva(reserva);
                  setState(() {});
                },
              )
            : null,
      ),
    );
  }

  void _mostrarFormularioNuevaReserva(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final _formKey = GlobalKey<FormState>();
    DateTime? fechaSeleccionada;
    LugarDisponible? lugarSeleccionado;
    String? vehiculoSeleccionado;
    int duracion = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Nueva Reserva"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<LugarDisponible>(
                    decoration: const InputDecoration(labelText: "Lugar disponible"),
                    value: controller.lugaresDisponibles
                            .where((l) => !l.ocupado)
                            .contains(lugarSeleccionado)
                        ? lugarSeleccionado
                        : null,
                    items: controller.lugaresDisponibles
                        .where((l) => !l.ocupado)
                        .map((l) => DropdownMenuItem(
                              value: l,
                              child: Text("${l.descripcionLugar} - \$${l.precioPorHora}/h"),
                            ))
                        .toList(),
                    onChanged: (lugar) {
                      setState(() => lugarSeleccionado = lugar);
                    },
                    validator: (value) => value == null ? 'Seleccione un lugar' : null,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: "Vehículo"),
                    value: controller.vehiculosUsuario.contains(vehiculoSeleccionado)
                        ? vehiculoSeleccionado
                        : null,
                    items: controller.vehiculosUsuario
                        .map((v) => DropdownMenuItem(
                              value: v,
                              child: Text(v),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => vehiculoSeleccionado = value),
                    validator: (value) => value == null ? 'Seleccione un vehículo' : null,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text("Duración (horas):"),
                      const SizedBox(width: 8),
                      DropdownButton<int>(
                        value: duracion,
                        onChanged: (value) => setState(() => duracion = value ?? 1),
                        items: List.generate(12, (index) => index + 1)
                            .map((h) => DropdownMenuItem(
                                  value: h,
                                  child: Text("$h h"),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      final DateTime? fecha = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );

                      if (fecha != null) {
                        final TimeOfDay? hora = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (hora != null) {
                          fechaSeleccionada = DateTime(
                            fecha.year,
                            fecha.month,
                            fecha.day,
                            hora.hour,
                            hora.minute,
                          );
                          setState(() {});
                        }
                      }
                    },
                    child: Text(
                      fechaSeleccionada == null
                          ? 'Seleccionar fecha y hora'
                          : fechaSeleccionada.toString(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() != true) return;

                final lugar = lugarSeleccionado!;
                final vehiculo = vehiculoSeleccionado!;

                await controller.crearReserva(
                  lugar: lugar,
                  duracionHoras: duracion,
                  vehiculo: vehiculo,
                  inicio: fechaSeleccionada ?? DateTime.now(),
                );

                Navigator.pop(context);
              },
              child: const Text("Confirmar"),
            ),
          ],
        ),
      ),
    );
  }
}
