import '../../domain/entities/campus_room_entity.dart';
import '../../domain/repositories/campus_room_repository.dart';

class MockCampusRoomRepository implements CampusRoomRepository {
  final List<CampusRoomEntity> _rooms = [
    const CampusRoomEntity(
      id: 'room-b-204',
      campusId: 'c0000001-0000-0000-0000-000000000001',
      building: 'Academic Block B',
      floor: '2nd Floor',
      roomNumber: '204',
      roomType: 'Lecture Hall',
      capacity: 80,
      isCurrentlyEmpty: true,
      currentClass: null,
      nextAvailableUntil: '03:30 PM (Free for 1h 45m)',
      todaySchedule: [
        RoomSlot(
          timeRange: '09:00 - 10:30 AM',
          subjectOrEvent: 'CS301 Algorithms',
          isOccupied: true,
        ),
        RoomSlot(
          timeRange: '10:45 - 12:15 PM',
          subjectOrEvent: 'CS304 Operating Systems',
          isOccupied: true,
        ),
        RoomSlot(
          timeRange: '01:00 - 03:30 PM',
          subjectOrEvent: 'Available / Self Study',
          isOccupied: false,
        ),
        RoomSlot(
          timeRange: '03:30 - 05:00 PM',
          subjectOrEvent: 'CS410 Machine Learning',
          isOccupied: true,
        ),
      ],
    ),
    const CampusRoomEntity(
      id: 'room-a-101',
      campusId: 'c0000001-0000-0000-0000-000000000001',
      building: 'Academic Block A',
      floor: '1st Floor',
      roomNumber: '101',
      roomType: 'Computer Lab',
      capacity: 45,
      isCurrentlyEmpty: false,
      currentClass: 'CS205 Data Structures Lab',
      nextAvailableUntil: 'Available at 04:00 PM',
      todaySchedule: [
        RoomSlot(
          timeRange: '09:00 - 01:00 PM',
          subjectOrEvent: 'Faculty Research Hours',
          isOccupied: true,
        ),
        RoomSlot(
          timeRange: '02:00 - 04:00 PM',
          subjectOrEvent: 'CS205 Data Structures Lab',
          isOccupied: true,
        ),
        RoomSlot(
          timeRange: '04:00 - 06:00 PM',
          subjectOrEvent: 'Open Lab Hours',
          isOccupied: false,
        ),
      ],
    ),
    const CampusRoomEntity(
      id: 'room-lib-201',
      campusId: 'c0000001-0000-0000-0000-000000000001',
      building: 'Central Library',
      floor: '2nd Floor',
      roomNumber: '201',
      roomType: 'Silent Reading Hall',
      capacity: 120,
      isCurrentlyEmpty: true,
      currentClass: null,
      nextAvailableUntil: 'Open until 09:00 PM',
      todaySchedule: [
        RoomSlot(
          timeRange: '08:00 AM - 09:00 PM',
          subjectOrEvent: 'Open Study Space',
          isOccupied: false,
        ),
      ],
    ),
    const CampusRoomEntity(
      id: 'room-b-302',
      campusId: 'c0000001-0000-0000-0000-000000000001',
      building: 'Academic Block B',
      floor: '3rd Floor',
      roomNumber: '302',
      roomType: 'Classroom',
      capacity: 60,
      isCurrentlyEmpty: true,
      currentClass: null,
      nextAvailableUntil: 'Free all afternoon until 05:00 PM',
      todaySchedule: [
        RoomSlot(
          timeRange: '10:00 - 11:30 AM',
          subjectOrEvent: 'Maths III Tutorial',
          isOccupied: true,
        ),
        RoomSlot(
          timeRange: '12:00 - 05:00 PM',
          subjectOrEvent: 'Unassigned / Open Class',
          isOccupied: false,
        ),
      ],
    ),
    const CampusRoomEntity(
      id: 'room-a-205',
      campusId: 'c0000001-0000-0000-0000-000000000001',
      building: 'Academic Block A',
      floor: '2nd Floor',
      roomNumber: '205',
      roomType: 'Seminar Hall',
      capacity: 150,
      isCurrentlyEmpty: false,
      currentClass: 'Industry Guest Lecture — AI in Robotics',
      nextAvailableUntil: 'Occupied until 04:30 PM',
      todaySchedule: [
        RoomSlot(
          timeRange: '01:30 - 04:30 PM',
          subjectOrEvent: 'Guest Lecture',
          isOccupied: true,
        ),
        RoomSlot(
          timeRange: '04:30 - 07:00 PM',
          subjectOrEvent: 'Available',
          isOccupied: false,
        ),
      ],
    ),
  ];

  @override
  Future<List<CampusRoomEntity>> getRooms({
    required String campusId,
    String? building,
    bool? onlyEmpty,
  }) async {
    await Future.delayed(const Duration(milliseconds: 10));
    var results = _rooms;
    if (building != null && building != 'All Buildings') {
      results = results.where((r) => r.building == building).toList();
    }
    if (onlyEmpty == true) {
      results = results.where((r) => r.isCurrentlyEmpty).toList();
    }
    return results;
  }

  @override
  Future<List<String>> getBuildings({required String campusId}) async {
    return [
      'All Buildings',
      'Academic Block A',
      'Academic Block B',
      'Central Library',
    ];
  }
}
