import 'package:uuid/uuid.dart';

import '../../core/network/supabase_client_manager.dart';
import '../../domain/entities/queue_entity.dart';
import '../../domain/repositories/queue_repository.dart';
import '../models/queue_model.dart';

class SupabaseQueueRepository implements QueueRepository {
  final SupabaseClientManager _clientManager;
  final List<QueueEntity> _mockQueues = [];
  final List<QueueTokenEntity> _mockTokens = [];

  SupabaseQueueRepository({SupabaseClientManager? clientManager})
    : _clientManager = clientManager ?? SupabaseClientManager.instance {
    _initMockData();
  }

  void _initMockData() {
    _mockQueues.addAll([
      const QueueModel(
        id: 'q-accounts',
        campusId: 'campus-alpha-001',
        serviceName: 'Accounts & Fee Counter',
        location: 'Administrative Block Room 102',
        isActive: true,
        currentToken: 22,
        waitingCount: 5,
      ),
      const QueueModel(
        id: 'q-admissions',
        campusId: 'campus-alpha-001',
        serviceName: 'Student ID & Document Verification',
        location: 'Student Affairs Counter 3',
        isActive: true,
        currentToken: 45,
        waitingCount: 2,
      ),
      const QueueModel(
        id: 'q-hostel',
        campusId: 'campus-alpha-001',
        serviceName: 'Hostel Allotment & Queries',
        location: 'Hostel Office Ground Floor',
        isActive: false,
        currentToken: 12,
        waitingCount: 0,
      ),
    ]);

    _mockTokens.add(
      QueueTokenModel(
        id: 't-27',
        queueId: 'q-accounts',
        userId: 'mock-user-123',
        tokenNumber: 27,
        status: TokenStatus.waiting,
        joinedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
    );
  }

  @override
  Future<List<QueueEntity>> getQueues({required String campusId}) async {
    final client = _clientManager.client;
    if (client != null) {
      final response = await client
          .from('queues')
          .select()
          .eq('campus_id', campusId)
          .order('service_name');
      return (response as List)
          .map((item) => QueueModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    await Future.delayed(const Duration(milliseconds: 150));
    return _mockQueues.where((e) => e.campusId == campusId).toList();
  }

  @override
  Future<QueueTokenEntity> joinQueue({
    required String queueId,
    required String userId,
  }) async {
    final client = _clientManager.client;
    if (client != null) {
      final nextToken = 28;
      final newId = 't-${const Uuid().v4().substring(0, 6)}';
      final token = QueueTokenModel(
        id: newId,
        queueId: queueId,
        userId: userId,
        tokenNumber: nextToken,
        status: TokenStatus.waiting,
        joinedAt: DateTime.now(),
      );
      await client.from('queue_tokens').insert(token.toJson());
      return token;
    }

    await Future.delayed(const Duration(milliseconds: 200));
    final queueIndex = _mockQueues.indexWhere((q) => q.id == queueId);
    int tokenNum = 1;
    if (queueIndex != -1) {
      final q = _mockQueues[queueIndex];
      tokenNum = q.currentToken + q.waitingCount + 1;
      _mockQueues[queueIndex] = QueueModel(
        id: q.id,
        campusId: q.campusId,
        serviceName: q.serviceName,
        location: q.location,
        isActive: q.isActive,
        currentToken: q.currentToken,
        waitingCount: q.waitingCount + 1,
      );
    }

    final token = QueueTokenModel(
      id: 't-${const Uuid().v4().substring(0, 6)}',
      queueId: queueId,
      userId: userId,
      tokenNumber: tokenNum,
      status: TokenStatus.waiting,
      joinedAt: DateTime.now(),
    );
    _mockTokens.add(token);
    return token;
  }

  @override
  Future<QueueTokenEntity?> getUserActiveToken({required String userId}) async {
    final client = _clientManager.client;
    if (client != null) {
      final response = await client
          .from('queue_tokens')
          .select()
          .eq('user_id', userId)
          .inFilter('status', ['waiting', 'called'])
          .maybeSingle();
      if (response == null) return null;
      return QueueTokenModel.fromJson(response);
    }

    await Future.delayed(const Duration(milliseconds: 100));
    final matching = _mockTokens.where(
      (t) =>
          t.userId == userId &&
          (t.status == TokenStatus.waiting || t.status == TokenStatus.called),
    );
    if (matching.isEmpty) return null;
    return matching.last;
  }
}
