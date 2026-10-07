import '../entities/campus_room_entity.dart';

abstract class CampusRoomRepository {
  Future<List<CampusRoomEntity>> getRooms({
    required String campusId,
    String? building,
    bool? onlyEmpty,
  });

  Future<List<String>> getBuildings({required String campusId});
}
