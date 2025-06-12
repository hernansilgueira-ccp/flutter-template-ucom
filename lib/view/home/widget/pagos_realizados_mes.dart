import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controller/dashboard_controller.dart';

class PagosRealizadosMes extends StatelessWidget {
  const PagosRealizadosMes({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find();

    return Obx(() {
      final pagosMes = controller.listaPagosEsteMes;
      if (pagosMes.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('No hay pagos realizados este mes.'),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Pagos realizados este mes',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pagosMes.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final pago = pagosMes[index];
              return ListTile(
                leading: const Icon(Icons.payment, color: Colors.green),
                title: Text('Reserva: ${pago.reservaId}'),
                subtitle: Text('Fecha: ${_formatearFechaHora(pago.fecha)}'),
                trailing: Text(
                  '\$${pago.monto.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
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