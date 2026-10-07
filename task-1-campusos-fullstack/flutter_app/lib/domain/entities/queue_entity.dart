import 'package:flutter/foundation.dart';

enum TokenStatus { waiting, called, served, cancelled }

@immutable
class QueueTokenEntity {
  final String id;
  final String queueId;
  final String userId;
  final int tokenNumber;
  final TokenStatus status;
  final DateTime joinedAt;
  final DateTime? servedAt;

  const QueueTokenEntity({
    required this.id,
    required this.queueId,
    required this.userId,
    required this.tokenNumber,
    required this.status,
    required this.joinedAt,
    this.servedAt,
  });
}

@immutable
class QueueEntity {
  final String id;
  final String campusId;
  final String serviceName;
  final String location;
  final bool isActive;
  final int currentToken;
  final int waitingCount;

  const QueueEntity({
    required this.id,
    required this.campusId,
    required this.serviceName,
    required this.location,
    required this.isActive,
    required this.currentToken,
    required this.waitingCount,
  });
}
