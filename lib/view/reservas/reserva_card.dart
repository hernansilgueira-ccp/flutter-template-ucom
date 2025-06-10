import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finpay/model/reservas_model.dart';
import 'package:finpay/view/reservas/reserva_detalle_view.dart';

class ReservaCard extends StatelessWidget {
  final Reserva reserva;
  final Color color;

  const ReservaCard({super.key, required this.reserva, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.2),
      child: InkWell(
        onTap: () {
          Get.to(() => ReservaDetalleView(reserva: reserva));
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lugar: ${reserva.lugar.nombre}', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Vehículo: ${reserva.vehiculo}'),
              Text('Inicio: ${reserva.inicio}'),
              Text('Duración: ${reserva.duracionHoras} h'),
              Text('Costo: \$${reserva.costo.toStringAsFixed(2)}'),
            ],
          ),
        ),
      ),
    );
  }
}
