import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finpay/controller/dashboard_controller.dart';
import 'package:finpay/model/lugar_disponible_model.dart';
import 'package:finpay/model/reservas_model.dart';

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
            backgroundImage: AssetImage(controller.usuario.value.avatar),
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioNuevaReserva(context), // ✅ CORRECTO
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReservaCard(Reserva reserva, Color color) {
  // Buscar el lugar asociado para obtener su precio por hora
    final lugar = controller.lugaresDisponibles.firstWhere(
  (l) => l.nombre.trim().toLowerCase() == reserva.lugar.nombre.trim().toLowerCase(),
  orElse: () => LugarDisponible(
    id: "N/A",
    nombre: reserva.lugar.nombre,
    precioPorHora: 0.0,
    ocupado: false,
  ),
);


    final montoTotal = lugar.precioPorHora * reserva.duracionHoras;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.local_parking, color: color),
        title: Text(reserva.lugar.nombre),
        subtitle: Text(
          "Vehículo: ${reserva.vehiculo}\n"
          "Inicio: ${reserva.fechaHoraInicio}\n"
          "Duración: ${reserva.duracionHoras}h\n"
          "Monto a pagar: \$${reserva.precio.toStringAsFixed(2)}",
        ),
        trailing: reserva.estado != EstadoReserva.completada
            ? IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: () async {
                  await controller.cancelarReserva(int.parse((reserva.id)));
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

    LugarDisponible? lugarSeleccionado;
    String? vehiculoSeleccionado;
    int duracion = 1;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
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
                              child: Text("${l.nombre} - \$${l.precioPorHora}/h"),
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
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState?.validate() != true) return;

                final lugar = lugarSeleccionado!;
                final vehiculo = vehiculoSeleccionado!;
                final duracionSeleccionada = duracion.toDouble();
          
                await controller.crearReserva(
                  lugarSeleccionado: lugar,
                  duracionHoras: duracionSeleccionada,
                  vehiculo: vehiculo,
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
