import 'package:flutter/material.dart';
import 'package:finpay/view/dashboard/dashboard_home.dart';
import 'package:finpay/view/profile/profile_view.dart';
import 'package:finpay/view/card/card_view.dart';

class DashboardView extends StatefulWidget {
  final int initialIndex;

  const DashboardView({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}



class _DashboardViewState extends State<DashboardView> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      DashboardHome(),
      const CardView(),
      const ProfileView(),
    ];

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

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() {
          _selectedIndex = index;
        }),
        items: _bottomItems,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
