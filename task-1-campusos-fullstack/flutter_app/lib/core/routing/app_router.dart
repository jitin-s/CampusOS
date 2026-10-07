import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_shell_screen.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/student_home_screen.dart';
import '../../features/dashboard/presentation/screens/student_shell_screen.dart';
import '../../features/campus_fix/presentation/screens/campus_fix_screen.dart';
import '../../features/lost_found/presentation/screens/lost_found_screen.dart';
import '../../features/queue/presentation/screens/queue_screen.dart';
import '../../features/notices/presentation/screens/notice_screen.dart';
import '../../features/activity/presentation/screens/activity_screen.dart';
import '../../features/rooms/presentation/screens/empty_rooms_screen.dart';
import '../../features/admin/presentation/screens/admin_issues_screen.dart';
import '../../features/admin/presentation/screens/admin_lost_found_screen.dart';
import '../../features/admin/presentation/screens/admin_queues_screen.dart';
import '../../features/admin/presentation/screens/admin_notices_screen.dart';
import '../../features/admin/presentation/screens/admin_analytics_screen.dart';
import '../../features/sos/presentation/screens/sos_emergency_screen.dart';

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
            builder: (context, state) => const CampusFixScreen(),
          ),
          GoRoute(
            path: '/student/lost-found',
            builder: (context, state) => const LostFoundScreen(),
          ),
          GoRoute(
            path: '/student/queue',
            builder: (context, state) => const QueueScreen(),
          ),
          GoRoute(
            path: '/student/notices',
            builder: (context, state) => const NoticeScreen(),
          ),
          GoRoute(
            path: '/student/rooms',
            builder: (context, state) => const EmptyRoomsScreen(),
          ),
          GoRoute(
            path: '/student/activity',
            builder: (context, state) => const ActivityScreen(),
          ),
          GoRoute(
            path: '/student/sos',
            builder: (context, state) => const SosEmergencyScreen(),
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
            builder: (context, state) => const AdminIssuesScreen(),
          ),
          GoRoute(
            path: '/admin/lost-found',
            builder: (context, state) => const AdminLostFoundScreen(),
          ),
          GoRoute(
            path: '/admin/queues',
            builder: (context, state) => const AdminQueuesScreen(),
          ),
          GoRoute(
            path: '/admin/notices',
            builder: (context, state) => const AdminNoticesScreen(),
          ),
          GoRoute(
            path: '/admin/analytics',
            builder: (context, state) => const AdminAnalyticsScreen(),
          ),
        ],
      ),
    ],
  );
}
