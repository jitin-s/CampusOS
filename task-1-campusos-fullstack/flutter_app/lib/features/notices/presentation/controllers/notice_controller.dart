import 'package:flutter/foundation.dart';

import '../../../../domain/entities/notice_entity.dart';
import '../../../../domain/repositories/notice_repository.dart';

class NoticeController extends ChangeNotifier {
  final NoticeRepository _repository;

  List<NoticeEntity> _notices = [];
  String _selectedCategory = 'All';
  bool _isLoading = false;
  String? _errorMessage;

  NoticeController({required NoticeRepository repository})
    : _repository = repository;

  List<NoticeEntity> get notices => _notices;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadNotices({required String campusId, String? category}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedCategory = category ?? 'All';
      _notices = await _repository.getNotices(
        campusId: campusId,
        category: _selectedCategory == 'All' ? null : _selectedCategory,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterCategory(String campusId, String category) {
    loadNotices(campusId: campusId, category: category);
  }
}
