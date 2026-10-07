import '../entities/lost_found_entity.dart';

abstract class LostFoundRepository {
  Future<List<LostFoundItemEntity>> getItems({
    required String campusId,
    ItemType? itemType,
    ItemStatus? status,
  });

  Future<LostFoundItemEntity> createItem(LostFoundItemEntity item);

  Future<void> updateItemStatus(String itemId, ItemStatus status);
}
