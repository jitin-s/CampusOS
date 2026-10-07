import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:campusos/core/theme/app_theme.dart';
import 'package:campusos/features/auth/presentation/controllers/auth_controller.dart';
import 'package:campusos/features/sos/presentation/widgets/sos_app_bar_button.dart';
import 'package:campusos/features/sos/presentation/widgets/sos_emergency_dialog.dart';

class StudentShellScreen extends StatelessWidget {
  final Widget child;

  const StudentShellScreen({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/student/home')) return 0;
    if (location.startsWith('/student/campus-fix')) return 1;
    if (location.startsWith('/student/lost-found')) return 2;
    if (location.startsWith('/student/queue')) return 3;
    if (location.startsWith('/student/rooms')) return 4;
    if (location.startsWith('/student/activity')) return 5;
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
        context.go('/student/rooms');
        break;
      case 5:
        context.go('/student/activity');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final selectedIndex = _calculateSelectedIndex(context);
    final user = context.watch<AuthController>().currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.secondaryNavy,
            boxShadow: [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // Brand Crest & Title
                  InkWell(
                    onTap: () => context.go('/student/home'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: const Icon(
                            Icons.school_outlined,
                            size: 22,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'Campus',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                Text(
                                  'OS',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.campusGreenBorder,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'COLLEGIATE WORKFLOW PORTAL',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Campus Status Green Pill (Desktop / Tablet)
                  if (MediaQuery.of(context).size.width >= 650)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.campusGreenDark.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.campusGreenBorder.withOpacity(0.4),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: AppTheme.campusGreenBorder,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Campus Systems Active',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),

                  // Desktop Navigation Links
                  if (isDesktop) ...[
                    _HeaderNavLink(
                      title: 'Home',
                      icon: Icons.dashboard_outlined,
                      isActive: selectedIndex == 0,
                      onTap: () => context.go('/student/home'),
                    ),
                    _HeaderNavLink(
                      title: 'CampusFix',
                      icon: Icons.build_outlined,
                      isActive: selectedIndex == 1,
                      onTap: () => context.go('/student/campus-fix'),
                    ),
                    _HeaderNavLink(
                      title: 'Lost & Found',
                      icon: Icons.search_outlined,
                      isActive: selectedIndex == 2,
                      onTap: () => context.go('/student/lost-found'),
                    ),
                    _HeaderNavLink(
                      title: 'Queue',
                      icon: Icons.confirmation_number_outlined,
                      isActive: selectedIndex == 3,
                      onTap: () => context.go('/student/queue'),
                    ),
                    _HeaderNavLink(
                      title: 'Study Rooms',
                      icon: Icons.meeting_room_outlined,
                      isActive: selectedIndex == 4,
                      onTap: () => context.go('/student/rooms'),
                    ),
                    _HeaderNavLink(
                      title: 'Notices',
                      icon: Icons.campaign_outlined,
                      isActive: false,
                      onTap: () => context.go('/student/notices'),
                    ),
                    const SizedBox(width: 12),
                  ],

                  // 🚨 Persistent SOS Emergency Action Button
                  const SosAppBarButton(),

                  const SizedBox(width: 8),

                  // User Info & Sign Out
                  if (user != null)
                    PopupMenuButton<String>(
                      tooltip: 'User Menu',
                      offset: const Offset(0, 48),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: AppTheme.primaryBlue,
                              child: Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (MediaQuery.of(context).size.width >= 550) ...[
                              const SizedBox(width: 8),
                              Text(
                                user.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                      onSelected: (val) async {
                        if (val == 'sos') {
                          SosEmergencyDialog.show(context);
                        } else if (val == 'admin') {
                          context.go('/admin/dashboard');
                        } else if (val == 'logout') {
                          await context.read<AuthController>().logout();
                          if (context.mounted) context.go('/login');
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          enabled: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                user.email,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'sos',
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: AppTheme.emergencyRed,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Emergency SOS Hub',
                                style: TextStyle(
                                  color: AppTheme.emergencyRed,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (user.isAdmin)
                          const PopupMenuItem(
                            value: 'admin',
                            child: Row(
                              children: [
                                Icon(Icons.admin_panel_settings, size: 18),
                                SizedBox(width: 8),
                                Text('Switch to Admin Console'),
                              ],
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, size: 18),
                              SizedBox(width: 8),
                              Text('Sign Out'),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: child,
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (idx) => _onItemTapped(idx, context),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.build_outlined),
                  selectedIcon: Icon(Icons.build),
                  label: 'CampusFix',
                ),
                NavigationDestination(
                  icon: Icon(Icons.search_outlined),
                  selectedIcon: Icon(Icons.search),
                  label: 'Lost/Found',
                ),
                NavigationDestination(
                  icon: Icon(Icons.confirmation_number_outlined),
                  selectedIcon: Icon(Icons.confirmation_number),
                  label: 'Queue',
                ),
                NavigationDestination(
                  icon: Icon(Icons.meeting_room_outlined),
                  selectedIcon: Icon(Icons.meeting_room),
                  label: 'Rooms',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history),
                  label: 'Activity',
                ),
              ],
            ),
    );
  }
}

class _HeaderNavLink extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _HeaderNavLink({
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TextButton.icon(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: isActive ? Colors.white : Colors.white.withOpacity(0.75),
          backgroundColor: isActive ? Colors.white.withOpacity(0.15) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        icon: Icon(icon, size: 16),
        label: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
