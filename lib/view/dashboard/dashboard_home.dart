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
            backgroundImage: controller.usuario.value.avatar.isNotEmpty
              ? AssetImage(controller.usuario.value.avatar)
              : const AssetImage('assets/images/default_avatar.png'),
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
        onPressed: () => mostrarFormularioNuevaReserva(context,controller), // ✅ CORRECTO
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReservaCard(Reserva reserva, Color color) {
  final lugar = controller.lugares.firstWhere(
    (l) => l.nombre.trim().toLowerCase() == reserva.lugar.nombre.trim().toLowerCase(),
    orElse: () => reserva.lugar,
  );

  // Buscar detalles del vehículo
  final vehiculo = controller.vehiculos.firstWhereOrNull(
    (v) => v.placa == reserva.vehiculo,
  );

  String vehiculoInfo;
  if (vehiculo != null) {
    vehiculoInfo = "${vehiculo.marca} ${vehiculo.modelo} (${vehiculo.placa}) - ${vehiculo.color}";
  } else {
    vehiculoInfo = reserva.vehiculo; // fallback si no lo encuentra
  }

  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: ListTile(
      leading: Icon(Icons.local_parking, color: color),
      title: Text(reserva.lugar.nombre),
      subtitle: Text(
        "Vehículo: $vehiculoInfo\n"
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




  void mostrarFormularioNuevaReserva(BuildContext context, DashboardController controller) {
  LugarDisponible? _lugarSeleccionado;
  String? _vehiculoSeleccionado;
  double _duracionHoras = 1;

  //if (controller.lugaresDisponibles.isEmpty || controller.vehiculosUsuario.isEmpty) {
  //  return const Center(child: Text("No hay lugares ni vehículos disponibles."));
  //}


  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Nueva Reserva"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dropdown de lugares disponibles
                DropdownButtonFormField<LugarDisponible>(
                  decoration: const InputDecoration(labelText: 'Lugar disponible'),
                  value: _lugarSeleccionado,
                  items: controller.lugaresDisponibles.map((lugar) {
                    return DropdownMenuItem(
                      value: lugar,
                      child: Text(lugar.nombre),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _lugarSeleccionado = value;
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Dropdown de vehículos del usuario
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Vehículo'),
                value: _vehiculoSeleccionado,
                items: controller.vehiculosUsuarioDetalles.map((vehiculo) {
                  return DropdownMenuItem(
                    value: vehiculo.placa,
                    child: Text('${vehiculo.marca} ${vehiculo.modelo} (${vehiculo.placa})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _vehiculoSeleccionado = value;
                  });
                },
              ),
                const SizedBox(height: 10),

                // Dropdown de duración
                DropdownButtonFormField<double>(
                  decoration: const InputDecoration(labelText: 'Duración (horas)'),
                  value: _duracionHoras,
                  items: [1.0, 1.5, 2.0, 2.5, 3.0, 4.0, 5.0].map((hora) {
                    return DropdownMenuItem(
                      value: hora,
                      child: Text('$hora h'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _duracionHoras = value!;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_lugarSeleccionado == null || _vehiculoSeleccionado == null) return;

                  final inicio = DateTime.now();
                  final fin = inicio.add(Duration(minutes: (_duracionHoras * 60).toInt()));
                  final costo = _lugarSeleccionado!.precioPorHora * _duracionHoras;

                  final reserva = Reserva(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    lugar: _lugarSeleccionado!,
                    vehiculo: _vehiculoSeleccionado!,
                    fechaHoraInicio: inicio,
                    fechaHoraFin: fin,
                    precio: costo,
                    estado: EstadoReserva.activa,
                    pagado: false,
                  );

                  controller.agregarReserva(reserva);
                  controller.update();
                  Navigator.pop(context);
                },
                child: const Text("Confirmar"),
              ),
            ],
          );
        },
      );
    },
  );
}

}
