import 'package:flutter/foundation.dart';

import '../../../../domain/entities/lost_found_entity.dart';
import '../../../../domain/repositories/lost_found_repository.dart';

class LostFoundController extends ChangeNotifier {
  final LostFoundRepository _repository;

  List<LostFoundItemEntity> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  LostFoundController({required LostFoundRepository repository})
    : _repository = repository;

  List<LostFoundItemEntity> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadItems({required String campusId, ItemType? itemType}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _repository.getItems(
        campusId: campusId,
        itemType: itemType,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<LostFoundItemEntity?> submitItem(LostFoundItemEntity item) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _repository.createItem(item);
      _items.insert(0, created);
      _isLoading = false;
      notifyListeners();
      return created;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> claimItem(String itemId) async {
    try {
      await _repository.updateItemStatus(itemId, ItemStatus.claimed);
      final index = _items.indexWhere((e) => e.id == itemId);
      if (index != -1) {
        final old = _items[index];
        _items[index] = LostFoundItemEntity(
          id: old.id,
          campusId: old.campusId,
          userId: old.userId,
          itemType: old.itemType,
          category: old.category,
          itemName: old.itemName,
          brand: old.brand,
          color: old.color,
          location: old.location,
          occurredAt: old.occurredAt,
          description: old.description,
          imageUrl: old.imageUrl,
          status: ItemStatus.claimed,
          createdAt: old.createdAt,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
