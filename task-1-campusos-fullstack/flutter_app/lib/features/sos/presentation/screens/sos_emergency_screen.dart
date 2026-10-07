import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:campusos/core/theme/app_theme.dart';
import 'package:campusos/features/auth/presentation/controllers/auth_controller.dart';
import 'package:campusos/features/sos/presentation/controllers/sos_controller.dart';
import 'package:campusos/features/sos/domain/entities/sos_alert_entity.dart';

class SosEmergencyScreen extends StatelessWidget {
  const SosEmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sos = context.watch<SosController>();
    final user = context.watch<AuthController>().currentUser;
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppTheme.backgroundCream,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: Colors.white),
            SizedBox(width: 8),
            Text('Campus Safety & SOS Emergency Hub'),
          ],
        ),
        backgroundColor: AppTheme.secondaryNavy,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 48.0 : 16.0,
          vertical: 24.0,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Emergency Banner
                _buildSafetyStatusBanner(context, sos),
                const SizedBox(height: 24),

                if (sos.isEmergencyActive) ...[
                  _buildLiveDispatchControl(context, sos),
                  const SizedBox(height: 24),
                ],

                // 2 Column Grid on Desktop, single column on mobile
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: _buildPanicTriggerSection(context, sos, user),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 4,
                        child: _buildEmergencyDirectories(context, sos),
                      ),
                    ],
                  )
                else ...[
                  _buildPanicTriggerSection(context, sos, user),
                  const SizedBox(height: 24),
                  _buildEmergencyDirectories(context, sos),
                ],

                const SizedBox(height: 32),
                _buildCampusSafetyGuidelines(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSafetyStatusBanner(BuildContext context, SosController sos) {
    final isAlert = sos.isEmergencyActive;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isAlert ? AppTheme.emergencyRedLight : AppTheme.campusGreenLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAlert ? AppTheme.emergencyRedBorder : AppTheme.campusGreenBorder,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isAlert ? AppTheme.emergencyRed : AppTheme.campusGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAlert ? Icons.warning_amber_rounded : Icons.check_circle,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAlert
                      ? 'CAMPUS EMERGENCY SIGNAL ACTIVE'
                      : 'Campus Safety Network: Active & Monitored 24/7',
                  style: TextStyle(
                    color: isAlert ? AppTheme.emergencyRed : AppTheme.campusGreenDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAlert
                      ? 'Emergency signal broadcasted. Security patrol has been dispatched to your designated coordinates.'
                      : 'CCTV surveillance, Rapid Response Patrols, and Automated Campus First Aid units operational.',
                  style: TextStyle(
                    color: isAlert
                        ? AppTheme.emergencyRed.withOpacity(0.9)
                        : AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveDispatchControl(BuildContext context, SosController sos) {
    final alert = sos.activeAlert;
    if (alert == null) return const SizedBox.shrink();

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.emergencyRed, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emergency, color: AppTheme.emergencyRed, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'ACTIVE INCIDENT: ${alert.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: AppTheme.emergencyRed,
                      ),
                    ),
                  ],
                ),
                Chip(
                  label: Text(
                    sos.status == SosDispatchStatus.enRoute
                        ? 'OFFICER EN ROUTE'
                        : 'DISPATCHED',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                  backgroundColor: AppTheme.emergencyRed,
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.shield, color: AppTheme.primaryBlue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Assigned Security Team: ${alert.assignedUnit}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.near_me, color: AppTheme.campusGreenDark, size: 20),
                const SizedBox(width: 8),
                Text(
                  'ETA: ${alert.estimatedArrival} | Location: ${alert.location}',
                  style: const TextStyle(fontSize: 13, color: AppTheme.campusGreenDark, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.campusGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle),
                    label: const Text(
                      'I AM SAFE (Stand Down)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => sos.resolveEmergency(),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.emergencyRed,
                    side: const BorderSide(color: AppTheme.emergencyRed),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.flash_on),
                  label: Text(sos.strobeActive ? 'Strobe ON' : 'Strobe OFF'),
                  onPressed: () => sos.toggleStrobe(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanicTriggerSection(
    BuildContext context,
    SosController sos,
    dynamic user,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.creamBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1-Tap Emergency Dispatch Trigger',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryNavy,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Select emergency category, confirm your campus location, and press the panic button.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),

            // Category Chips
            const Text(
              'Emergency Category',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SosEmergencyType.values.map((t) {
                final selected = sos.selectedType == t;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        t.icon,
                        size: 16,
                        color: selected ? Colors.white : t.color,
                      ),
                      const SizedBox(width: 6),
                      Text(t.title),
                    ],
                  ),
                  selected: selected,
                  selectedColor: t.color,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  onSelected: (_) => sos.setSelectedType(t),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            const Text(
              'Your Current Campus Location',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppTheme.backgroundCream,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.creamBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: sos.selectedLocation,
                  icon: const Icon(Icons.pin_drop, color: AppTheme.primaryBlue),
                  items: sos.campusLocations.map((loc) {
                    return DropdownMenuItem(value: loc, child: Text(loc, style: const TextStyle(fontSize: 13)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) sos.setSelectedLocation(val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Trigger Buttons
            if (sos.status == SosDispatchStatus.countingDown) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.emergencyRedLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.emergencyRed),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.emergencyRed,
                      radius: 20,
                      child: Text(
                        '${sos.countdownRemaining}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dispatching in progress...',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.emergencyRed,
                            ),
                          ),
                          Text(
                            'Tap cancel if this was an accidental press.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => sos.cancelCountdown(),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.emergencyRed,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.warning, size: 22),
                        label: const Text(
                          'TRIGGER EMERGENCY SOS (3s Buffer)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            fontSize: 14,
                          ),
                        ),
                        onPressed: () {
                          sos.startSosCountdown(
                            studentName: user?.name ?? 'Student',
                            studentEmail: user?.email ?? 'student@campus.edu',
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.emergencyRed,
                        side: const BorderSide(color: AppTheme.emergencyRed, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.bolt, size: 20),
                      label: const Text(
                        'Instant',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        sos.triggerImmediateSos(
                          studentName: user?.name ?? 'Student',
                          studentEmail: user?.email ?? 'student@campus.edu',
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyDirectories(BuildContext context, SosController sos) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.creamBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.phone_in_talk, color: AppTheme.primaryBlue, size: 22),
                SizedBox(width: 8),
                Text(
                  'Campus Emergency Hotlines',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Direct lines to campus responders',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            ...sos.emergencyContacts.map((c) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundCream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.creamBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.softBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(c.icon, color: AppTheme.primaryBlue, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Text(
                            '${c.phoneNumber} (${c.extension})',
                            style: const TextStyle(fontSize: 11, color: AppTheme.campusGreenDark, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.call, color: AppTheme.campusGreen),
                      tooltip: 'Call ${c.name}',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Calling ${c.name} on ${c.phoneNumber}'),
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
      ),
    );
  }

  Widget _buildCampusSafetyGuidelines(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.creamBorder),
      ),
      child: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Campus Safety Protocols & Emergency Instructions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppTheme.secondaryNavy,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ProtocolItem(
                    icon: Icons.shield,
                    title: 'SafeWalk Escort',
                    desc: 'Security guards are available 24/7 to escort students across campus after 9 PM.',
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _ProtocolItem(
                    icon: Icons.local_hospital,
                    title: 'AED & First Aid',
                    desc: 'Automated External Defibrillators are located on every ground floor lobby.',
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _ProtocolItem(
                    icon: Icons.fire_extinguisher,
                    title: 'Assembly Areas',
                    desc: 'Main assembly point is the Central Quadrangle and Sports Stadium field.',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProtocolItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _ProtocolItem({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryBlue),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
