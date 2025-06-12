import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/dashboard_controller.dart';

class HomeFeatureCounters extends StatelessWidget {
  const HomeFeatureCounters({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController dashboardController = Get.find();

    return Obx(() {
      final pagosMes = dashboardController.pagos.where((p) {
        final ahora = DateTime.now();
        return p.fecha.year == ahora.year && p.fecha.month == ahora.month;
      }).length;

      final pagosPendientes = dashboardController.reservas.where((r) => !r.pagado).length;

      final cantidadAutos = dashboardController.usuario.value.vehiculos.length;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _featureCard(
              context,
              icon: Icons.check_circle,
              color: Colors.green,
              value: '$pagosMes',
              label: 'Pagos este mes',
            ),
            _featureCard(
              context,
              icon: Icons.warning_rounded,
              color: Colors.orange,
              value: '$pagosPendientes',
              label: 'Pendientes',
            ),
            _featureCard(
              context,
              icon: Icons.directions_car,
              color: Colors.blue,
              value: '$cantidadAutos',
              label: 'Autos',
            ),
          ],
        ),
      );
    });
  }

  Widget _featureCard(BuildContext context, {
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}