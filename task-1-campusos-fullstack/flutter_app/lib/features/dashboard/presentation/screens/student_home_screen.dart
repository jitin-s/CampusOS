import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../sos/presentation/controllers/sos_controller.dart';
import '../../../sos/presentation/widgets/sos_emergency_dialog.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final sos = context.watch<SosController>();
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 32.0 : 16.0,
        vertical: 20.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Welcome Banner
              _buildHeroBanner(context, user?.name ?? 'Scholar'),
              const SizedBox(height: 20),

              // SOS Emergency Priority Callout
              _buildSosEmergencyCallout(context, sos),
              const SizedBox(height: 24),

              // Live Campus Vitals (4 KPI Metric Cards in Blue, Cream, Green)
              _buildCampusVitals(context),
              const SizedBox(height: 28),

              // Quick Actions Grid (6 Modern Cards)
              Text(
                'Campus Operations & Services',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryNavy,
                      letterSpacing: -0.3,
                    ),
              ),
              const SizedBox(height: 14),
              _buildActionGrid(context),
              const SizedBox(height: 28),

              // My Active Workflows & Status Stepper
              Text(
                'My Active Campus Requests',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryNavy,
                      letterSpacing: -0.3,
                    ),
              ),
              const SizedBox(height: 14),
              _buildActiveRequestsCard(context),
              const SizedBox(height: 28),

              // Campus Safety & Hotline Bar
              _buildEmergencyHotlineBanner(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, String userName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F1E36),
            Color(0xFF1E3A8A),
            Color(0xFF1D4ED8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F1E3A8A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.campusGreenDark.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.campusGreenBorder.withOpacity(0.6),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 12,
                            color: AppTheme.campusGreenBorder,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Fall 2026 • Live Campus Operating Layer',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Good afternoon, $userName',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Track repairs, find vacant study rooms, claim lost items, and reach rapid assistance 24/7.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (MediaQuery.of(context).size.width >= 700) ...[
            const SizedBox(width: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.security,
                    size: 32,
                    color: AppTheme.campusGreenBorder,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Campus Security',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Patrol Active',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSosEmergencyCallout(BuildContext context, SosController sos) {
    final isActive = sos.isEmergencyActive;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.emergencyRedLight : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? AppTheme.emergencyRedBorder
              : const Color(0xFFFDBA74),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.emergencyRed
                  : const Color(0xFFEA580C),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sos_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isActive
                          ? '🚨 ACTIVE SOS DISPATCH IN PROGRESS'
                          : 'Campus SOS Emergency & Safety Dispatch',
                      style: TextStyle(
                        color: isActive
                            ? AppTheme.emergencyRed
                            : const Color(0xFF9A3412),
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppTheme.emergencyRed
                            : AppTheme.campusGreenDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isActive ? 'ALERT ON' : '24/7 ACTIVE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isActive
                      ? 'Security Officer is responding to your location. Tap to view status or stand down.'
                      : 'Immediate physical security, ambulance, SafeWalk escorts, and fire hazard response.',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isActive
                  ? AppTheme.emergencyRed
                  : const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.shield, size: 18),
            label: Text(
              isActive ? 'VIEW SOS STATUS' : 'EMERGENCY SOS',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
            onPressed: () {
              SosEmergencyDialog.show(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCampusVitals(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth >= 800 ? 4 : 2;
        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: constraints.maxWidth >= 800 ? 2.3 : 1.9,
          children: const [
            _VitalCard(
              title: 'Facilities Health',
              value: '99.4%',
              subtitle: 'Wi-Fi, Labs & AC Active',
              icon: Icons.check_circle_outline,
              accentColor: AppTheme.campusGreenDark,
              bgColor: AppTheme.campusGreenLight,
            ),
            _VitalCard(
              title: 'Queue Wait Time',
              value: '8-12 min',
              subtitle: 'Registrar & Accounts',
              icon: Icons.hourglass_top_outlined,
              accentColor: AppTheme.accentBlue,
              bgColor: AppTheme.softBlue,
            ),
            _VitalCard(
              title: 'Vacant Study Desks',
              value: '14 Halls',
              subtitle: 'Library & Sci Block Open',
              icon: Icons.meeting_room_outlined,
              accentColor: AppTheme.campusGreenDark,
              bgColor: AppTheme.campusGreenLight,
            ),
            _VitalCard(
              title: 'Emergency QRF',
              value: '< 2 mins',
              subtitle: 'Rapid Security Response',
              icon: Icons.bolt,
              accentColor: AppTheme.emergencyRed,
              bgColor: AppTheme.emergencyRedLight,
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;
        final count = isDesktop ? 3 : 2;
        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: isDesktop ? 1.6 : 1.25,
          children: [
            _ServiceActionCard(
              title: 'CampusFix',
              badge: 'REPORT ISSUE',
              subtitle: 'Report classrooms, electrical, lab equipment & Wi-Fi problems',
              icon: Icons.build_circle_outlined,
              primaryColor: AppTheme.primaryBlue,
              accentTint: AppTheme.softBlue,
              onTap: () => context.go('/student/campus-fix'),
            ),
            _ServiceActionCard(
              title: 'Lost & Found',
              badge: 'SMART RECOVERY',
              subtitle: 'AI attribute matching to reclaim lost campus belongings',
              icon: Icons.find_in_page_outlined,
              primaryColor: const Color(0xFFD97706),
              accentTint: const Color(0xFFFEF3C7),
              onTap: () => context.go('/student/lost-found'),
            ),
            _ServiceActionCard(
              title: 'Digital Queue',
              badge: 'VIRTUAL TOKEN',
              subtitle: 'Join administrative queues with live wait time radar',
              icon: Icons.confirmation_number_outlined,
              primaryColor: AppTheme.accentBlue,
              accentTint: AppTheme.softBlue,
              onTap: () => context.go('/student/queue'),
            ),
            _ServiceActionCard(
              title: 'Empty Study Rooms',
              badge: 'CAMPUS SPACES',
              subtitle: 'Find real-time quiet spots, lecture halls & collaborative rooms',
              icon: Icons.meeting_room_outlined,
              primaryColor: AppTheme.campusGreenDark,
              accentTint: AppTheme.campusGreenLight,
              onTap: () => context.go('/student/rooms'),
            ),
            _ServiceActionCard(
              title: 'Campus Notices',
              badge: 'OFFICIAL BULLETINS',
              subtitle: 'Timely university circulars, exam alerts & schedules',
              icon: Icons.campaign_outlined,
              primaryColor: const Color(0xFF4338CA),
              accentTint: const Color(0xFFEEF2FF),
              onTap: () => context.go('/student/notices'),
            ),
            _ServiceActionCard(
              title: 'SOS Emergency Hub',
              badge: 'RAPID DEFENSE',
              subtitle: 'Immediate security escort, ambulance, & panic alert system',
              icon: Icons.shield_outlined,
              primaryColor: AppTheme.emergencyRed,
              accentTint: AppTheme.emergencyRedLight,
              onTap: () => SosEmergencyDialog.show(context),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActiveRequestsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.creamBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.softBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.build,
                    color: AppTheme.primaryBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Broken Overhead Projector (Academic Block B - Room 204)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Reported today at 11:20 AM • Assigned to IT Maintenance Team',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.campusGreenLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.campusGreenBorder),
                  ),
                  child: const Text(
                    'Technician Assigned',
                    style: TextStyle(
                      color: AppTheme.campusGreenDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.creamBorder),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 16,
                      color: AppTheme.campusGreenDark,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Expected Resolution: Today by 4:00 PM',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => context.go('/student/activity'),
                  icon: const Icon(Icons.arrow_forward, size: 14),
                  label: const Text('View All Tracking History'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyHotlineBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.secondaryNavy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppTheme.emergencyRed,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone_in_talk, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Campus 24/7 Rapid Emergency Response Lines',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Security: 1800-CAMPUS-911 | Ambulance: Ext 108 | SafeWalk: 1091',
                  style: TextStyle(
                    color: AppTheme.campusGreenBorder,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.secondaryNavy,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            onPressed: () => SosEmergencyDialog.show(context),
            child: const Text(
              'Call Help',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _VitalCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color bgColor;

  const _VitalCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.creamBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: accentColor,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceActionCard extends StatelessWidget {
  final String title;
  final String badge;
  final String subtitle;
  final IconData icon;
  final Color primaryColor;
  final Color accentTint;
  final VoidCallback onTap;

  const _ServiceActionCard({
    required this.title,
    required this.badge,
    required this.subtitle,
    required this.icon,
    required this.primaryColor,
    required this.accentTint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.creamBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentTint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 26, color: primaryColor),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: accentTint,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.secondaryNavy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
