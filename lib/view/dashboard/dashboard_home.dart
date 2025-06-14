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
            ...controller.reservasActuales
            .where((r) {
              final lugarActual = controller.lugares.firstWhere(
                (l) => l.id == r.lugar.id,
                orElse: () => r.lugar,
              );
              return !lugarActual.ocupado;
            })
            .map((r) => _buildReservaCard(r, Colors.green)),
            
            const SizedBox(height: 20),
            const Text("Próximas reservas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...controller.reservasProximas
            .where((r) {
              final lugarActual = controller.lugares.firstWhere(
                (l) => l.id == r.lugar.id,
                orElse: () => r.lugar,
              );
              return !lugarActual.ocupado;
            })
            .map((r) => _buildReservaCard(r, Colors.blue)),

            const SizedBox(height: 20),
            const Text("Historial", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...controller.reservasHistorial
            .where((r) {
              final lugarActual = controller.lugares.firstWhere(
                (l) => l.id == r.lugar.id,
                orElse: () => r.lugar,
              );
              return !lugarActual.ocupado;
            })
            .map((r) => _buildReservaCard(r, Colors.grey)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => mostrarFormularioNuevaReserva(context,controller),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReservaCard(Reserva reserva, Color color) {
    final lugar = controller.lugares.firstWhere(
      (l) => l.nombre.trim().toLowerCase() == reserva.lugar.nombre.trim().toLowerCase(),
      orElse: () => reserva.lugar,
    );

    final bool ocupado = lugar.ocupado;
    final Color codigoColor = ocupado ? Colors.red : Colors.green;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.local_parking, color: color),
        title: Text(
          'Código: ${lugar.id}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: codigoColor,
          ),
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
                  // Dropdown de lugares disponibles (solo código, coloreado, deshabilita los ocupados)
                  DropdownButtonFormField<LugarDisponible>(
  decoration: const InputDecoration(labelText: 'Código del lugar'),
  value: _lugarSeleccionado,
  items: controller.lugaresDisponibles
      .where((lugar) => !lugar.ocupado) // solo los libres
      .map((lugar) {
        return DropdownMenuItem<LugarDisponible>(
          value: lugar,
          child: Text(
            'Código: ${lugar.id}',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
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