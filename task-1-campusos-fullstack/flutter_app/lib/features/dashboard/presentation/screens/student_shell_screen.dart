import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:campusos/features/auth/presentation/controllers/auth_controller.dart';

class StudentShellScreen extends StatelessWidget {
  final Widget child;

  const StudentShellScreen({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/student/home')) return 0;
    if (location.startsWith('/student/campus-fix')) return 1;
    if (location.startsWith('/student/lost-found')) return 2;
    if (location.startsWith('/student/queue')) return 3;
    if (location.startsWith('/student/activity')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/student/home');
        break;
      case 1:
        context.go('/student/campus-fix');
        break;
      case 2:
        context.go('/student/lost-found');
        break;
      case 3:
        context.go('/student/queue');
        break;
      case 4:
        context.go('/student/activity');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    final user = context.watch<AuthController>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.school, size: 24, color: Colors.white),
            const SizedBox(width: 8),
            const Text('CampusOS'),
            const Spacer(),
            if (user != null)
              Text(
                'Hi, ${user.name}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await context.read<AuthController>().logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (idx) => _onItemTapped(idx, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            label: 'CampusFix',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            label: 'Lost & Found',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            label: 'Queue',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: 'Activity'),
        ],
      ),
    );
  }
}
