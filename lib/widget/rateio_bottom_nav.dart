import 'package:flutter/material.dart';

class RateioBottomNav extends StatelessWidget {
  const RateioBottomNav({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  static const _routes = <String>[
    'rateio_dashboard',
    'participantes',
    'pagamentos',
    'rateio_mensal',
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        if (index == currentIndex) return;
        Navigator.pushReplacementNamed(context, _routes[index]);
      },
      destinations: const <NavigationDestination>[
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Resumo',
        ),
        NavigationDestination(
          icon: Icon(Icons.groups_outlined),
          selectedIcon: Icon(Icons.groups),
          label: 'Pessoas',
        ),
        NavigationDestination(
          icon: Icon(Icons.payments_outlined),
          selectedIcon: Icon(Icons.payments),
          label: 'Pagamentos',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month),
          label: 'Rateio',
        ),
      ],
    );
  }
}
