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

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.reservasActuales.isNotEmpty)
                  _buildSection("Reservas Actuales", controller.reservasActuales),
                if (controller.reservasProximas.isNotEmpty)
                  _buildSection("Próximas Reservas", controller.reservasProximas),
                if (controller.reservasHistorial.isNotEmpty)
                  _buildSection("Historial", controller.reservasHistorial),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioReserva(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSection(String title, List<Reserva> reservas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...reservas.map(_buildReservaCard).toList(),
      ],
    );
  }

  Widget _buildReservaCard(Reserva r) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(Icons.local_parking, color: _estadoColor(r.estado)),
        title: Text(r.lugar, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          "${r.inicio.day}/${r.inicio.month}/${r.inicio.year} "
          "- ${r.duracionHoras.toInt()}h\n"
          "Estado: ${r.estado.name}",
        ),
        trailing: Text(
          "\$${r.costo.toStringAsFixed(2)}",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
        onTap: () => Get.to(() => ReservaDetalleView(reserva: r)),
      ),
    );
  }

  Color _estadoColor(EstadoReserva estado) {
    switch (estado) {
      case EstadoReserva.actual:
        return Colors.green;
      case EstadoReserva.proxima:
        return Colors.orange;
      case EstadoReserva.historial:
        return Colors.grey;
    }
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
                    decoration: const InputDecoration(labelText: "Lugar disponible"),
                    items: controller.lugaresDisponibles
                        .where((l) => !l.ocupado)
                        .map((l) => DropdownMenuItem(
                              value: l,
                              child: Text("${l.nombre} - \$${l.precioPorHora}/h"),
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
                          vehiculo: vehiculoSeleccionado ?? controller.vehiculosUsuario.first,
                          inicio: fechaInicio,
                          duracionHoras: duracion.toDouble(),
                          costo: lugarSeleccionado!.precioPorHora * duracion,
                          estado: EstadoReserva.proxima,
                        );

                        controller.reservas.add(reserva);
                        controller.ocuparLugar(reserva.lugar);
                        controller.guardarReservas();

                        Get.back();
                        Get.snackbar("✅ Reserva creada", "Tu nueva reserva fue agendada correctamente.");
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
