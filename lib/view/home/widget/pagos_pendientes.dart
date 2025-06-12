import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/dashboard_controller.dart';

class PagosPendientes extends StatelessWidget {
  const PagosPendientes({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find();

    return Obx(() {
      final pendientes = controller.reservasPendientes;
      if (pendientes.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('No tienes pagos pendientes.'),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Pagos pendientes',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pendientes.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final r = pendientes[index];
              return ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                title: Text("Lugar: ${r.lugar.nombre}"),
                subtitle: Text("Fecha: ${_formatearFechaHora(r.fechaHoraInicio)}"),
                trailing: Text(
                  "\$${r.precio.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              );
            },
          ),
        ],
      );
    });
  }

  static String _formatearFechaHora(DateTime fecha) {
    return "${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year} ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}";
  }
}