import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/placeholder_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_shell_screen.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/student_home_screen.dart';
import '../../features/dashboard/presentation/screens/student_shell_screen.dart';

GoRouter createRouter(AuthController authController) {
  return GoRouter(
    initialLocation: '/student/home',
    refreshListenable: authController,
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = authController.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      if (isAuthenticated && isLoggingIn) {
        return authController.currentUser?.isAdmin == true
            ? '/admin/dashboard'
            : '/student/home';
      }

      // Role Guard: Restrict /admin to Admin role (docs/02_SRD.md FR-001)
      if (state.matchedLocation.startsWith('/admin') &&
          authController.currentUser?.isAdmin != true) {
        return '/student/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      // Student route shell
      ShellRoute(
        builder: (context, state, child) => StudentShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/student/home',
            builder: (context, state) => const StudentHomeScreen(),
          ),
          GoRoute(
            path: '/student/campus-fix',
            builder: (context, state) => const PlaceholderScreen(
              title: 'CampusFix',
              description:
                  'Report and track campus maintenance and facility issues.',
              icon: Icons.build_outlined,
            ),
          ),
          GoRoute(
            path: '/student/lost-found',
            builder: (context, state) => const PlaceholderScreen(
              title: 'Lost & Found',
              description:
                  'Smart item matching, claims and ownership verification.',
              icon: Icons.search_outlined,
            ),
          ),
          GoRoute(
            path: '/student/queue',
            builder: (context, state) => const PlaceholderScreen(
              title: 'Digital Queue',
              description:
                  'Join service queues and view real-time token progress.',
              icon: Icons.people_outline,
            ),
          ),
          GoRoute(
            path: '/student/notices',
            builder: (context, state) => const PlaceholderScreen(
              title: 'Campus Notices',
              description:
                  'Important announcements, exams, and deadline bulletins.',
              icon: Icons.notifications_none,
            ),
          ),
          GoRoute(
            path: '/student/activity',
            builder: (context, state) => const PlaceholderScreen(
              title: 'My Activity',
              description: 'Unified timeline of your campus requests and status updates.',
              icon: Icons.history,
            ),
          ),
        ],
      ),
      // Admin route shell
      ShellRoute(
        builder: (context, state, child) => AdminShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/issues',
            builder: (context, state) => const PlaceholderScreen(
              title: 'Manage CampusFix Issues',
              description: 'Review classified issues, assign departments and update statuses.',
              icon: Icons.build_outlined,
            ),
          ),
          GoRoute(
            path: '/admin/lost-found',
            builder: (context, state) => const PlaceholderScreen(
              title: 'Lost & Found Claims',
              description: 'Verify claims and coordinate item recoveries.',
              icon: Icons.search_outlined,
            ),
          ),
          GoRoute(
            path: '/admin/queues',
            builder: (context, state) => const PlaceholderScreen(
              title: 'Queue Management',
              description: 'Open, close, and call tokens for campus counters.',
              icon: Icons.people_outline,
            ),
          ),
          GoRoute(
            path: '/admin/notices',
            builder: (context, state) => const PlaceholderScreen(
              title: 'Publish Notices',
              description: 'Compose and dispatch campus bulletins to students and faculty.',
              icon: Icons.notifications_none,
            ),
          ),
          GoRoute(
            path: '/admin/analytics',
            builder: (context, state) => const PlaceholderScreen(
              title: 'Campus Intelligence & Analytics',
              description: 'Resolution times, recovery rates, issue density and campus reliability score.',
              icon: Icons.analytics_outlined,
            ),
          ),
        ],
      ),
    ],
  );
}
