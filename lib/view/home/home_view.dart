// ignore_for_file: deprecated_member_use

import 'package:card_swiper/card_swiper.dart';
import 'package:finpay/config/images.dart';
import 'package:finpay/config/textstyle.dart';
import 'package:finpay/controller/home_controller.dart';
import 'package:finpay/utils/utiles.dart';
import 'package:finpay/view/dashboard/dashboard_view.dart';
import 'package:finpay/view/home/widget/circle_card.dart';
import 'package:finpay/view/home/widget/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controller/dashboard_controller.dart';
import 'package:finpay/view/home/widget/home_feature_counters.dart';
import 'package:finpay/view/home/widget/pagos_realizados_mes.dart';
import 'package:finpay/view/home/widget/pagos_pendientes.dart';

class HomeView extends StatelessWidget {
  final HomeController homeController;

  const HomeView({super.key, required this.homeController});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.isLightTheme == false
          ? const Color(0xff15141F)
          : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Good morning",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).textTheme.bodySmall!.color,
                      ),
                    ),
                    Text(
                      "Good morning",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      height: 28,
                      width: 69,
                      decoration: BoxDecoration(
                        color: const Color(0xffF6A609).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(DefaultImages.ranking),
                          Text(
                            "Gold",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                              color: const Color(0xffF6A609),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: Image.asset(DefaultImages.avatar),
                    )
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.isLightTheme == false
                              ? HexColor('#15141f')
                              : Theme.of(context).appBarTheme.backgroundColor,
                          border: Border.all(
                            color: HexColor(AppTheme.primaryColorString!)
                                .withOpacity(0.05),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              customContainer(
                                title: "USD",
                                background: AppTheme.primaryColorString,
                                textColor: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              customContainer(
                                title: "IDR",
                                background: AppTheme.isLightTheme == false
                                    ? '#211F32'
                                    : "#FFFFFF",
                                textColor: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color,
                              )
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.add,
                            color: HexColor(AppTheme.primaryColorString!),
                            size: 20,
                          ),
                          Text(
                            "Add Currency",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                              color: HexColor(AppTheme.primaryColorString!),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                /*
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    height: 180,
                    width: Get.width,
                    child: Swiper(
                      itemBuilder: (BuildContext context, int index) {
                        return SvgPicture.asset(
                          DefaultImages.debitcard,
                          fit: BoxFit.fill,
                        );
                      },
                      itemCount: 3,
                      viewportFraction: 1,
                      scale: 0.9,
                      autoplay: true,
                      itemWidth: Get.width,
                      itemHeight: 180,
                    ),
                  ),
                ),
                const SizedBox(height: 20),*/
                const HomeFeatureCounters(),
                const PagosRealizadosMes(),
                const SizedBox(height: 20),
                const PagosPendientes(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      focusColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () async {
                        final controller = Get.find<DashboardController>();
                        final reservas = controller.reservasNoPagadas;

                        if (reservas.isEmpty) {
                          Get.snackbar('Sin reservas pendientes', 'No tienes reservas por pagar.');
                          return;
                        }

                        // Estado local para las reservas seleccionadas
                        List<int> seleccionadas = [];

                        await Get.dialog(
                          StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                title: const Text('Selecciona reservas para pagar'),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: reservas.length,
                                    itemBuilder: (context, index) {
                                      final reserva = reservas[index];
                                      final selected = seleccionadas.contains(index);
                                      return Card(
                                        margin: const EdgeInsets.symmetric(vertical: 8),
                                        color: selected ? Colors.green.withOpacity(0.15) : null,
                                        child: ListTile(
                                          leading: Checkbox(
                                            value: selected,
                                            onChanged: (value) {
                                              setState(() {
                                                if (value == true) {
                                                  seleccionadas.add(index);
                                                } else {
                                                  seleccionadas.remove(index);
                                                }
                                              });
                                            },
                                          ),
                                          title: Text('Lugar: ${reserva.lugar}'),
                                          subtitle: Text(
                                            'Fecha: ${reserva.fechaHoraInicio.toString().split(" ")[0]} - Costo: \$${reserva.precio.toStringAsFixed(2)}',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('Cerrar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: seleccionadas.isEmpty
                                        ? null
                                        : () async {
                                      final confirmar = await Get.dialog(
                                        AlertDialog(
                                          title: const Text('¿Confirmar pago?'),
                                          content: Text(
                                            '¿Deseas pagar las ${seleccionadas.length} reservas seleccionadas?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Get.back(result: false),
                                              child: const Text('Cancelar'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                              ),
                                              onPressed: () => Get.back(result: true),
                                              child: const Text('Pagar'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirmar == true) {
                                        for (final idx in seleccionadas) {
                                          await controller.registrarPago(reservas[idx],'Tarjeta de crédito');
                                          reservas[idx].pagado = true;
                                          reservas[idx].lugar.ocupado = false;

                                          //await controller.pagarReservaActual(reservas[idx],'Tarjeta de crédito');
                                        }
                                        Get.back(); // cerrar selección
                                        Get.snackbar('Pago realizado',
                                            'Reservas pagadas correctamente');
                                      }
                                    },
                                    child: const Text('Pagar seleccionados'),
                                  ),
                                ],
                              );
                            },
                          ),
                        );
                      },
                      child: circleCard(
                        image: DefaultImages.pay,
                        title: "Pagar",
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: circleCard(
                        image: DefaultImages.withdraw,
                        title: "Withdraw",
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Get.to(
                          () => const DashboardView(),
                          transition: Transition.downToUp,
                          duration: const Duration(milliseconds: 500),
                        );
                      },
                      child: circleCard(
                        image: DefaultImages.transfer,
                        title: "Reservar",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.isLightTheme == false
                          ? const Color(0xff211F32)
                          : const Color(0xffFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff000000).withOpacity(0.10),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Pagos previos",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Obx(() {
                          return Column(
                            children: homeController.pagosPrevios.map((pago) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: const Icon(Icons.payments_outlined),
                                  title: Text("Reserva: ${pago.codigoReservaAsociada}"),
                                  subtitle: Text("Fecha: ${UtilesApp.formatearFechaDdMMAaaa(pago.fechaPago)}"),
                                  trailing: Text(
                                    "- ${UtilesApp.formatearGuaranies(pago.montoPagado)}",
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          )
        ],
      ),
    );
  }
}