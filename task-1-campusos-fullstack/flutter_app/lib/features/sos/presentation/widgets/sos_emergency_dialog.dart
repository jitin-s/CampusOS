import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campusos/core/theme/app_theme.dart';
import 'package:campusos/features/auth/presentation/controllers/auth_controller.dart';
import 'package:campusos/features/sos/presentation/controllers/sos_controller.dart';
import 'package:campusos/features/sos/domain/entities/sos_alert_entity.dart';

class SosEmergencyDialog extends StatelessWidget {
  const SosEmergencyDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SosEmergencyDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 680 : double.infinity,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceCream,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.creamBorder, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              Expanded(
                child: Consumer<SosController>(
                  builder: (context, sos, _) {
                    if (sos.isEmergencyActive) {
                      return _buildActiveAlertView(context, sos);
                    }
                    if (sos.status == SosDispatchStatus.countingDown) {
                      return _buildCountdownView(context, sos);
                    }
                    return _buildTriggerView(context, sos);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppTheme.secondaryNavy,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppTheme.emergencyRed,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.sos, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CAMPUS EMERGENCY SOS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '24/7 Rapid Response Dispatch • Control Desk Ext 100',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildTriggerView(BuildContext context, SosController sos) {
    final user = context.watch<AuthController>().currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Security Banner Notice
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.emergencyRedLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.emergencyRedBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.emergencyRed,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Triggering SOS alerts Campus Rapid Response Guards with your live profile and coordinates.',
                    style: TextStyle(
                      color: AppTheme.emergencyRed.withOpacity(0.95),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          const Text(
            '1. Select Emergency Type',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryNavy,
            ),
          ),
          const SizedBox(height: 10),

          // Emergency Category Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.1,
            children: SosEmergencyType.values.map((type) {
              final isSelected = sos.selectedType == type;
              return InkWell(
                onTap: () => sos.setSelectedType(type),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? type.color.withOpacity(0.12)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? type.color : AppTheme.creamBorder,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: type.color.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(type.icon, color: type.color, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              type.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: isSelected
                                    ? type.color
                                    : AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              type.description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 18),
          const Text(
            '2. Confirm Your Campus Location',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryNavy,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.creamBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: sos.selectedLocation,
                icon: const Icon(Icons.location_on, color: AppTheme.primaryBlue),
                items: sos.campusLocations.map((loc) {
                  return DropdownMenuItem(
                    value: loc,
                    child: Text(
                      loc,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) sos.setSelectedLocation(val);
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Big Red Panic Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.emergencyRed,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.notifications_active, size: 24),
              label: const Text(
                'DISPATCH SOS ALERT NOW (3s Safety Buffer)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  fontSize: 15,
                ),
              ),
              onPressed: () {
                sos.startSosCountdown(
                  studentName: user?.name ?? 'Campus Resident',
                  studentEmail: user?.email ?? 'student@campus.edu',
                );
              },
            ),
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          // Quick Dial Emergency Hotlines
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Direct Campus Emergency Lines',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.campusGreenLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '● 24/7 Available',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.campusGreenDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          ...sos.emergencyContacts.map((contact) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.creamBorder),
              ),
              child: Row(
                children: [
                  Icon(contact.icon, size: 20, color: AppTheme.primaryBlue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${contact.phoneNumber} (${contact.extension})',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.campusGreenDark,
                      side: const BorderSide(color: AppTheme.campusGreen),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.call, size: 14),
                    label: const Text('Call', style: TextStyle(fontSize: 11)),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Dialing ${contact.name}: ${contact.phoneNumber}'),
                          backgroundColor: AppTheme.secondaryNavy,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCountdownView(BuildContext context, SosController sos) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppTheme.emergencyRedLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.emergencyRed, width: 4),
              ),
              child: Center(
                child: Text(
                  '${sos.countdownRemaining}',
                  style: const TextStyle(
                    fontSize: 54,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.emergencyRed,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'DISPATCHING SOS TO CAMPUS SECURITY...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: AppTheme.secondaryNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Location: ${sos.selectedLocation}\nType: ${sos.selectedType.title}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 260,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text(
                  'CANCEL (False Alarm)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => sos.cancelCountdown(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveAlertView(BuildContext context, SosController sos) {
    final alert = sos.activeAlert;
    if (alert == null) return const SizedBox.shrink();

    final isEnRoute = sos.status == SosDispatchStatus.enRoute;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Active Pulse Badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.emergencyRed,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_police,
                  color: Colors.white,
                  size: 36,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DISPATCH ACTIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'Alert ID: ${alert.id} • ${alert.type.title}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isEnRoute ? 'EN ROUTE' : 'DISPATCHED',
                    style: const TextStyle(
                      color: AppTheme.emergencyRed,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Unit Assignment Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppTheme.creamBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.shield, color: AppTheme.primaryBlue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        alert.assignedUnit,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: AppTheme.campusGreenDark, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Estimated Arrival: ${alert.estimatedArrival}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.campusGreenDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.pin_drop, color: Colors.grey, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Location: ${alert.location}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Strobe Beacon Simulation
          SwitchListTile(
            title: const Text(
              'Visual Flash Beacon (Attract Help)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Pulses screen display bright red & white for visual locate',
              style: TextStyle(fontSize: 11),
            ),
            value: sos.strobeActive,
            activeThumbColor: AppTheme.emergencyRed,
            onChanged: (val) => sos.toggleStrobe(),
          ),

          const SizedBox(height: 18),

          // Resolve / Stand Down Button
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.campusGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                'I AM SAFE • STAND DOWN EMERGENCY',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              onPressed: () {
                sos.resolveEmergency();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Emergency alert closed. Security notified that you are safe.'),
                    backgroundColor: AppTheme.campusGreenDark,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
