import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finpay/controller/dashboard_controller.dart';
import 'package:finpay/model/reservas_model.dart';
import 'package:finpay/model/lugar_disponible_model.dart';
import 'package:finpay/view/reservas/reserva_detalle_view.dart';

class DashboardHome extends StatelessWidget {
  final DashboardController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final user = controller.usuario.value;
          return Row(
            children: [
              CircleAvatar(backgroundImage: AssetImage(user.avatarUrl)),
              const SizedBox(width: 10),
              Text("Hola, ${user.nombre}", style: const TextStyle(fontSize: 18)),
            ],
          );
        }),
      ),
      body: Obx(() {
        if (controller.reservas.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: [
            if (controller.reservasActuales.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text("Reservas Actuales", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ...controller.reservasActuales.map((r) => _buildReservaCard(r)),
            ],
            if (controller.reservasProximas.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text("Reservas Próximas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ...controller.reservasProximas.map((r) => _buildReservaCard(r)),
            ],
            if (controller.reservasHistorial.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text("Historial", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ...controller.reservasHistorial.map((r) => _buildReservaCard(r)),
            ],
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioReserva(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReservaCard(Reserva r) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.local_parking),
        title: Text(r.lugar),
        subtitle: Text(
          "${r.inicio.day}/${r.inicio.month}/${r.inicio.year} - ${r.duracionHoras}h\nEstado: ${r.estado.name}",
        ),
        trailing: Text(
          "\$${r.costo}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: () {
          Get.to(() => ReservaDetalleView(reserva: r));
        },
      ),
    );
  }

  void _mostrarFormularioReserva(BuildContext context) {
    LugarDisponible? lugarSeleccionado;
    int duracion = 1;
    String? vehiculoSeleccionado;
    DateTime fechaInicio = DateTime.now().add(const Duration(minutes: 5));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: const Text("Nueva Reserva"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<LugarDisponible>(
                    decoration: const InputDecoration(labelText: "Lugar"),
                    items: controller.lugaresDisponibles
                        .where((l) => !l.ocupado)
                        .map((l) => DropdownMenuItem(
                              value: l,
                              child: Text("${l.nombre} (\$${l.precioPorHora}/h)"),
                            ))
                        .toList(),
                    onChanged: (lugar) => setState(() => lugarSeleccionado = lugar),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    initialValue: duracion.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Duración (horas)"),
                    onChanged: (val) {
                      final h = int.tryParse(val) ?? 1;
                      setState(() => duracion = h < 1 ? 1 : h);
                    },
                  ),
                  const SizedBox(height: 10),
                  if (controller.vehiculosUsuario.length > 1)
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: "Vehículo"),
                      items: controller.vehiculosUsuario
                          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: (v) => setState(() => vehiculoSeleccionado = v),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text("Cancelar"),
                onPressed: () => Get.back(),
              ),
              ElevatedButton(
                onPressed: (lugarSeleccionado != null &&
                        duracion > 0 &&
                        (controller.vehiculosUsuario.length == 1 ||
                            vehiculoSeleccionado != null))
                    ? () {
                        final reserva = Reserva(
                          lugar: lugarSeleccionado!.nombre,
                          vehiculo: vehiculoSeleccionado ??
                              controller.vehiculosUsuario.first,
                          inicio: fechaInicio,
                          duracionHoras: duracion.toDouble(),
                          costo: lugarSeleccionado!.precioPorHora * duracion,
                          estado: EstadoReserva.proxima,
                        );

                        controller.reservas.add(reserva);
                        final index = controller.lugaresDisponibles.indexWhere(
                            (l) => l.id == lugarSeleccionado!.id);
                        if (index != -1) {
                          controller.lugaresDisponibles[index].ocupado = true;
                          controller.lugaresDisponibles.refresh();
                        }

                        Get.back();
                        Get.snackbar("Reserva creada", "Tu nueva reserva fue agendada.");
                      }
                    : null,
                child: const Text("Confirmar"),
              ),
            ],
          );
        });
      },
    );
  }
}
