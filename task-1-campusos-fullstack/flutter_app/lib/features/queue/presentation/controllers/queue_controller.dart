import 'package:flutter/foundation.dart';

import '../../../../domain/entities/queue_entity.dart';
import '../../../../domain/repositories/queue_repository.dart';

class QueueController extends ChangeNotifier {
  final QueueRepository _repository;

  List<QueueEntity> _queues = [];
  QueueTokenEntity? _activeToken;
  bool _isLoading = false;
  String? _errorMessage;

  QueueController({required QueueRepository repository})
    : _repository = repository;

  List<QueueEntity> get queues => _queues;
  QueueTokenEntity? get activeToken => _activeToken;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadQueues({
    required String campusId,
    required String userId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _queues = await _repository.getQueues(campusId: campusId);
      _activeToken = await _repository.getUserActiveToken(userId: userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<QueueTokenEntity?> joinQueue({
    required String queueId,
    required String userId,
    required String campusId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _repository.joinQueue(
        queueId: queueId,
        userId: userId,
      );
      _activeToken = token;
      _queues = await _repository.getQueues(campusId: campusId);
      _isLoading = false;
      notifyListeners();
      return token;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
