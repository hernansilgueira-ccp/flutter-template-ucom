import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finpay/controller/dashboard_controller.dart';
import 'package:finpay/model/reservas_model.dart';
import 'package:finpay/model/lugar_disponible_model.dart';

class FormularioReserva extends StatefulWidget {
  final DashboardController controller;

  const FormularioReserva({super.key, required this.controller});

  @override
  State<FormularioReserva> createState() => _FormularioReservaState();
}

class _FormularioReservaState extends State<FormularioReserva> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _vehiculoController = TextEditingController();
  DateTime? _fechaInicio;
  double _duracionHoras = 1;
  LugarDisponible? _lugarSeleccionado;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Vehículo
          TextFormField(
            controller: _vehiculoController,
            decoration: const InputDecoration(labelText: 'Vehículo'),
            validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
          ),

          const SizedBox(height: 12),

          // Fecha de inicio
          ListTile(
            title: Text(
              _fechaInicio == null
                  ? 'Seleccionar fecha y hora'
                  : _fechaInicio.toString(),
            ),
            trailing: const Icon(Icons.calendar_today),
            onTap: _seleccionarFecha,
          ),

          const SizedBox(height: 12),

          // Duración
          Slider(
            label: 'Duración: ${_duracionHoras.toInt()} h',
            min: 1,
            max: 12,
            divisions: 11,
            value: _duracionHoras,
            onChanged: (value) {
              setState(() {
                _duracionHoras = value;
              });
            },
          ),

          const SizedBox(height: 12),

          // Lugar disponible
          DropdownButtonFormField<LugarDisponible>(
            decoration: const InputDecoration(labelText: 'Lugar disponible'),
            value: _lugarSeleccionado,
            items: widget.controller.lugaresDisponibles
              .where((l) => !l.ocupado)
              .map((lugar) => DropdownMenuItem(
                value: lugar,
                child: Text('${lugar.nombre} (\$${lugar.precioPorHora}/h)'),
              )).toList(),
            onChanged: (lugar) {
              setState(() {
                _lugarSeleccionado = lugar;
              });
            },
            validator: (value) => value == null ? 'Selecciona un lugar' : null,
          ),

          const SizedBox(height: 16),

          // Botón guardar
          ElevatedButton(
            onPressed: _crearReserva,
            child: const Text('Confirmar Reserva'),
          ),
        ],
      ),
    ));
  }

  Future<void> _seleccionarFecha() async {
    final now = DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );

    if (fecha != null) {
      final hora = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );

      if (hora != null) {
        setState(() {
          _fechaInicio = DateTime(
            fecha.year,
            fecha.month,
            fecha.day,
            hora.hour,
            hora.minute,
          );
        });
      }
    }
  }

  void _crearReserva() {
    if (!_formKey.currentState!.validate() || _fechaInicio == null || _lugarSeleccionado == null) return;

    final lugar = _lugarSeleccionado!;
    final fechaFin = _fechaInicio!.add(Duration(hours: _duracionHoras.toInt()));
    final costo = lugar.precioPorHora * _duracionHoras;


    final nuevaReserva = Reserva(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lugar: lugar,
      vehiculo: _vehiculoController.text,
      fechaHoraInicio: _fechaInicio!,
      fechaHoraFin: fechaFin,
      //duracionHoras: _duracionHoras,
      precio: costo,
      estado: EstadoReserva.activa,
      pagado: false,
    );

    widget.controller.agregarReserva(nuevaReserva);
    Get.back(); // Cierra el diálogo
  }
}
