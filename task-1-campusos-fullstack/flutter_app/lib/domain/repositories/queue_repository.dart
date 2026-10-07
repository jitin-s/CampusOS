import '../entities/queue_entity.dart';

abstract class QueueRepository {
  Future<List<QueueEntity>> getQueues({required String campusId});
  Future<QueueTokenEntity> joinQueue({
    required String queueId,
    required String userId,
  });
  Future<QueueTokenEntity?> getUserActiveToken({required String userId});
}
