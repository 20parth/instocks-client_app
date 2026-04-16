import 'package:flutter/material.dart';

import '../notifications/notifications_screen.dart';
import '../portfolio/portfolio_detail_screen.dart';
import '../portfolio/portfolios_screen.dart';
import '../profile/profile_screen.dart';
import '../reports/reports_screen.dart';
import 'dashboard_screen.dart';

class ClientShell extends StatefulWidget {
  const ClientShell({super.key});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int _index = 0;

  late final List<Widget> _screens = const [
    DashboardScreen(),
    PortfoliosScreen(),
    ReportsScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.wallet_rounded), label: 'Portfolios'),
          NavigationDestination(
              icon: Icon(Icons.analytics_rounded), label: 'Reports'),
          NavigationDestination(
              icon: Icon(Icons.notifications_rounded), label: 'Alerts'),
          NavigationDestination(
              icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
