import 'package:flutter/material.dart';
import 'package:finpay/view/dashboard/dashboard_home.dart';
import 'package:finpay/view/profile/profile_view.dart';
import 'package:finpay/view/card/card_view.dart';

class DashboardView extends StatefulWidget {
  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    DashboardHome(),
    CardView(),
    ProfileView(),
  ];

  final List<String> _titles = [
    'Inicio',
    'Métodos de Pago',
    'Perfil',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<BottomNavigationBarItem> _bottomItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'Inicio',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.credit_card),
      label: 'Pagos',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Perfil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: _bottomItems,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
