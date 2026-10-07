import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/campus_room_controller.dart';

class EmptyRoomsScreen extends StatefulWidget {
  const EmptyRoomsScreen({super.key});

  @override
  State<EmptyRoomsScreen> createState() => _EmptyRoomsScreenState();
}

class _EmptyRoomsScreenState extends State<EmptyRoomsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthController>().currentUser;
      if (user != null) {
        context.read<CampusRoomController>().loadRooms(user.campusId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthController>().currentUser;
    final controller = context.watch<CampusRoomController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Empty Rooms & Study Spaces'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.secondaryNavy,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: controller.selectedBuilding,
                        decoration: const InputDecoration(
                          labelText: 'Filter by Building',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: controller.buildings
                            .map(
                              (b) => DropdownMenuItem(value: b, child: Text(b)),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null && user != null) {
                            controller.filterBuilding(user.campusId, val);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        const Text(
                          'Only Empty',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Switch(
                          value: controller.onlyEmpty,
                          activeThumbColor: AppTheme.statusResolved,
                          onChanged: (val) {
                            if (user != null) {
                              controller.toggleOnlyEmpty(user.campusId, val);
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: controller.isLoading && controller.rooms.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : controller.rooms.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.meeting_room_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No empty rooms right now in this building.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try toggling "Only Empty" off to view schedules.',
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.rooms.length,
                    itemBuilder: (context, index) {
                      final room = controller.rooms[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: room.isCurrentlyEmpty
                              ? const BorderSide(
                                  color: Color(0xFF86EFAC),
                                  width: 1.5,
                                )
                              : BorderSide.none,
                        ),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: room.isCurrentlyEmpty
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEE2E2),
                            child: Icon(
                              room.isCurrentlyEmpty
                                  ? Icons.check
                                  : Icons.lock_clock,
                              color: room.isCurrentlyEmpty
                                  ? Colors.green[800]
                                  : Colors.red[800],
                              size: 20,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                'Room ${room.roomNumber}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Chip(
                                label: Text(
                                  room.roomType,
                                  style: const TextStyle(fontSize: 10),
                                ),
                                backgroundColor: Colors.grey[100],
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          subtitle: Text(
                            '${room.building} (${room.floor}) • Capacity: ${room.capacity}\n${room.isCurrentlyEmpty ? "FREE NOW: ${room.nextAvailableUntil}" : "OCCUPIED: ${room.currentClass}"}',
                            style: TextStyle(
                              fontSize: 12,
                              color: room.isCurrentlyEmpty
                                  ? Colors.green[800]
                                  : Colors.red[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          childrenPadding: const EdgeInsets.all(16),
                          children: [
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Today\'s Timetable & Slot Breakdown:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 8),
                            for (final slot in room.todaySchedule)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      slot.timeRange,
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          slot.subjectOrEvent,
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: slot.isOccupied
                                                ? const Color(0xFFFEE2E2)
                                                : const Color(0xFFDCFCE7),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            slot.isOccupied ? 'Class' : 'Empty',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: slot.isOccupied
                                                  ? Colors.red[800]
                                                  : Colors.green[800],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ],
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
