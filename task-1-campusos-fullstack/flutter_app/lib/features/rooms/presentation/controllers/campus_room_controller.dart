import 'package:flutter/foundation.dart';

import '../../../../domain/entities/campus_room_entity.dart';
import '../../../../domain/repositories/campus_room_repository.dart';

class CampusRoomController extends ChangeNotifier {
  final CampusRoomRepository _repository;

  List<CampusRoomEntity> _rooms = [];
  List<String> _buildings = ['All Buildings'];
  String _selectedBuilding = 'All Buildings';
  bool _onlyEmpty = true;
  bool _isLoading = false;
  String? _errorMessage;

  CampusRoomController({required CampusRoomRepository repository})
    : _repository = repository;

  List<CampusRoomEntity> get rooms => _rooms;
  List<String> get buildings => _buildings;
  String get selectedBuilding => _selectedBuilding;
  bool get onlyEmpty => _onlyEmpty;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadRooms(String campusId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _buildings = await _repository.getBuildings(campusId: campusId);
      _rooms = await _repository.getRooms(
        campusId: campusId,
        building: _selectedBuilding,
        onlyEmpty: _onlyEmpty ? true : null,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterBuilding(String campusId, String building) async {
    _selectedBuilding = building;
    await loadRooms(campusId);
  }

  Future<void> toggleOnlyEmpty(String campusId, bool value) async {
    _onlyEmpty = value;
    await loadRooms(campusId);
  }
}
