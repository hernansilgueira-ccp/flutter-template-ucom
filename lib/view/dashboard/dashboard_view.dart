import 'package:finpay/view/statistics/statistics_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finpay/controller/dashboard_controller.dart';
import 'package:finpay/view/dashboard/dashboard_home.dart';
import 'package:finpay/view/card/card_view.dart';
import 'package:finpay/view/profile/profile_view.dart';

class DashboardView extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());
  final RxInt selectedIndex = 0.obs;

  final List<Widget> pages = [
    DashboardHome(),
    CardView(),
    ProfileView(),
    StatisticsView(),
  ];

  DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
          body: pages[selectedIndex.value],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: selectedIndex.value,
            onTap: (index) => selectedIndex.value = index,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: 'Card'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
            ],
          ),
        ));
  }
  
}
