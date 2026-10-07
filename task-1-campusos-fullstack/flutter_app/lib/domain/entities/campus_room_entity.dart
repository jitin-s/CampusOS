/// Entity model representing a campus classroom/lab and its current availability schedule.
class CampusRoomEntity {
  final String id;
  final String campusId;
  final String building;
  final String floor;
  final String roomNumber;
  final String roomType; // Classroom, Computer Lab, Lecture Hall, Seminar Room
  final int capacity;
  final bool isCurrentlyEmpty;
  final String? currentClass;
  final String nextAvailableUntil;
  final List<RoomSlot> todaySchedule;

  const CampusRoomEntity({
    required this.id,
    required this.campusId,
    required this.building,
    required this.floor,
    required this.roomNumber,
    required this.roomType,
    required this.capacity,
    required this.isCurrentlyEmpty,
    this.currentClass,
    required this.nextAvailableUntil,
    required this.todaySchedule,
  });
}

class RoomSlot {
  final String timeRange;
  final String subjectOrEvent;
  final bool isOccupied;

  const RoomSlot({
    required this.timeRange,
    required this.subjectOrEvent,
    required this.isOccupied,
  });
}
