import 'package:uuid/uuid.dart';

import '../../core/network/supabase_client_manager.dart';
import '../../domain/entities/lost_found_entity.dart';
import '../../domain/repositories/lost_found_repository.dart';
import '../models/lost_found_item_model.dart';

class SupabaseLostFoundRepository implements LostFoundRepository {
  final SupabaseClientManager _clientManager;
  final List<LostFoundItemEntity> _mockItems = [];

  SupabaseLostFoundRepository({SupabaseClientManager? clientManager})
    : _clientManager = clientManager ?? SupabaseClientManager.instance {
    _initMockData();
  }

  void _initMockData() {
    _mockItems.addAll([
      LostFoundItemModel(
        id: 'lf-001',
        campusId: 'campus-alpha-001',
        userId: 'other-user-456',
        itemType: ItemType.found,
        category: 'Electronics',
        itemName: 'Casio Scientific Calculator FX-991EX',
        brand: 'Casio',
        color: 'Black / White',
        location: 'Central Library, 2nd Floor study cubicles',
        occurredAt: DateTime.now().subtract(const Duration(hours: 3)),
        description:
            'Black and white casing, barcode sticker slightly faded on back.',
        status: ItemStatus.open,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      LostFoundItemModel(
        id: 'lf-002',
        campusId: 'campus-alpha-001',
        userId: 'mock-user-123',
        itemType: ItemType.lost,
        category: 'Electronics',
        itemName: 'Casio Scientific Calculator',
        brand: 'Casio',
        color: 'Black',
        location: 'Library Reading Hall',
        occurredAt: DateTime.now().subtract(const Duration(hours: 4)),
        description: 'Lost during afternoon study session.',
        status: ItemStatus.matched,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      LostFoundItemModel(
        id: 'lf-003',
        campusId: 'campus-alpha-001',
        userId: 'user-789',
        itemType: ItemType.found,
        category: 'Accessories',
        itemName: 'Water Bottle Stainless Steel',
        brand: 'Milton',
        color: 'Silver/Blue',
        location: 'Cafeteria Ground Floor',
        occurredAt: DateTime.now().subtract(const Duration(days: 1)),
        description: 'Silver 750ml bottle with blue silicone strap.',
        status: ItemStatus.open,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
  }

  @override
  Future<List<LostFoundItemEntity>> getItems({
    required String campusId,
    ItemType? itemType,
    ItemStatus? status,
  }) async {
    final client = _clientManager.client;
    if (client != null) {
      var query = client
          .from('lost_found_items')
          .select()
          .eq('campus_id', campusId);
      if (itemType != null) {
        query = query.eq('item_type', itemType.name);
      }
      if (status != null) {
        query = query.eq('status', status.name);
      }
      final response = await query.order('created_at', ascending: false);
      return (response as List)
          .map(
            (item) => LostFoundItemModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }

    await Future.delayed(const Duration(milliseconds: 150));
    var results = _mockItems.where((e) => e.campusId == campusId);
    if (itemType != null) {
      results = results.where((e) => e.itemType == itemType);
    }
    if (status != null) {
      results = results.where((e) => e.status == status);
    }
    return results.toList();
  }

  @override
  Future<LostFoundItemEntity> createItem(LostFoundItemEntity item) async {
    final newId = 'lf-${const Uuid().v4().substring(0, 6)}';
    final model = LostFoundItemModel(
      id: newId,
      campusId: item.campusId,
      userId: item.userId,
      itemType: item.itemType,
      category: item.category,
      itemName: item.itemName,
      brand: item.brand,
      color: item.color,
      location: item.location,
      occurredAt: item.occurredAt,
      description: item.description,
      imageUrl: item.imageUrl,
      status: item.status,
      createdAt: DateTime.now(),
    );

    final client = _clientManager.client;
    if (client != null) {
      await client.from('lost_found_items').insert(model.toJson());
      return model;
    }

    await Future.delayed(const Duration(milliseconds: 200));
    _mockItems.insert(0, model);
    return model;
  }

  @override
  Future<void> updateItemStatus(String itemId, ItemStatus status) async {
    final client = _clientManager.client;
    if (client != null) {
      await client
          .from('lost_found_items')
          .update({'status': status.name})
          .eq('id', itemId);
      return;
    }

    await Future.delayed(const Duration(milliseconds: 100));
    final index = _mockItems.indexWhere((e) => e.id == itemId);
    if (index != -1) {
      final old = _mockItems[index];
      _mockItems[index] = LostFoundItemModel(
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
        status: status,
        createdAt: old.createdAt,
      );
    }
  }
}
