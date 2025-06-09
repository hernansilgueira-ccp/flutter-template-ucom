import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finpay/controller/dashboard_controller.dart';

class ReservasProximasWidget extends StatelessWidget {
  const ReservasProximasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Obx(() {
      final reservas = controller.reservasProximas;

      if (reservas.isEmpty) {
        return const SizedBox(); // o un Text('No hay reservas próximas')
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reservas Próximas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...reservas.map((r) => ListTile(
                leading: const Icon(Icons.schedule),
                title: Text(r.lugar),
                subtitle: Text(
                  '${r.inicio} - ${r.vehiculo}',
                  style: const TextStyle(fontSize: 12),
                ),
              )),
        ],
      );
    });
  }
}
