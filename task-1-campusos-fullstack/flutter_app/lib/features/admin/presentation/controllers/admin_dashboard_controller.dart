import 'package:flutter/foundation.dart';

import '../../../../domain/entities/intelligence_models.dart';
import '../../../../domain/entities/issue_entity.dart';
import '../../../../domain/entities/lost_found_entity.dart';
import '../../../../domain/entities/notice_entity.dart';
import '../../../../domain/entities/queue_entity.dart';
import '../../../../domain/repositories/issue_repository.dart';
import '../../../../domain/repositories/lost_found_repository.dart';
import '../../../../domain/repositories/notice_repository.dart';
import '../../../../domain/repositories/queue_repository.dart';
import '../../../../domain/services/intelligence_service.dart';

class AdminDashboardController extends ChangeNotifier {
  final IssueRepository _issueRepository;
  final LostFoundRepository _lostFoundRepository;
  final QueueRepository _queueRepository;
  final NoticeRepository _noticeRepository;
  final IntelligenceService _intelligenceService;

  List<IssueEntity> _issues = [];
  List<LostFoundItemEntity> _lostFoundItems = [];
  List<QueueEntity> _queues = [];
  List<NoticeEntity> _notices = [];
  CampusAnalyticsModel? _analytics;
  bool _isLoading = false;
  String? _errorMessage;

  AdminDashboardController({
    required IssueRepository issueRepository,
    required LostFoundRepository lostFoundRepository,
    required QueueRepository queueRepository,
    required NoticeRepository noticeRepository,
    required IntelligenceService intelligenceService,
  }) : _issueRepository = issueRepository,
       _lostFoundRepository = lostFoundRepository,
       _queueRepository = queueRepository,
       _noticeRepository = noticeRepository,
       _intelligenceService = intelligenceService;

  List<IssueEntity> get issues => _issues;
  List<LostFoundItemEntity> get lostFoundItems => _lostFoundItems;
  List<QueueEntity> get queues => _queues;
  List<NoticeEntity> get notices => _notices;
  CampusAnalyticsModel? get analytics => _analytics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboardData(String campusId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _issues = await _issueRepository.getIssues(campusId: campusId);
      _lostFoundItems = await _lostFoundRepository.getItems(campusId: campusId);
      _queues = await _queueRepository.getQueues(campusId: campusId);
      _notices = await _noticeRepository.getNotices(campusId: campusId);

      _analytics = _intelligenceService.calculateCampusAnalytics(
        issues: _issues,
        lostItems: _lostFoundItems
            .where((i) => i.itemType == ItemType.lost)
            .toList(),
        foundItems: _lostFoundItems
            .where((i) => i.itemType == ItemType.found)
            .toList(),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> assignIssue({
    required String issueId,
    required String departmentId,
    required String assignedTo,
  }) async {
    await _issueRepository.assignIssue(
      issueId: issueId,
      departmentId: departmentId,
      assignedTo: assignedTo,
    );
    final idx = _issues.indexWhere((i) => i.id == issueId);
    if (idx != -1) {
      final old = _issues[idx];
      _issues[idx] = IssueEntity(
        id: old.id,
        campusId: old.campusId,
        reporterId: old.reporterId,
        category: old.category,
        type: old.type,
        description: old.description,
        locationId: old.locationId,
        severity: old.severity,
        departmentId: departmentId,
        assignedTo: assignedTo,
        status: IssueStatus.assigned,
        beforeImageUrl: old.beforeImageUrl,
        afterImageUrl: old.afterImageUrl,
        createdAt: old.createdAt,
      );
      notifyListeners();
    }
  }

  Future<void> updateIssueStatus({
    required String issueId,
    required IssueStatus newStatus,
  }) async {
    await _issueRepository.updateStatus(issueId: issueId, newStatus: newStatus);
    final idx = _issues.indexWhere((i) => i.id == issueId);
    if (idx != -1) {
      final old = _issues[idx];
      _issues[idx] = IssueEntity(
        id: old.id,
        campusId: old.campusId,
        reporterId: old.reporterId,
        category: old.category,
        type: old.type,
        description: old.description,
        locationId: old.locationId,
        severity: old.severity,
        departmentId: old.departmentId,
        assignedTo: old.assignedTo,
        status: newStatus,
        beforeImageUrl: old.beforeImageUrl,
        afterImageUrl: old.afterImageUrl,
        createdAt: old.createdAt,
        resolvedAt: newStatus == IssueStatus.resolved
            ? DateTime.now()
            : old.resolvedAt,
      );
      notifyListeners();
    }
  }

  Future<void> approveClaim(String itemId) async {
    await _lostFoundRepository.updateItemStatus(itemId, ItemStatus.recovered);
    final idx = _lostFoundItems.indexWhere((i) => i.id == itemId);
    if (idx != -1) {
      final old = _lostFoundItems[idx];
      _lostFoundItems[idx] = LostFoundItemEntity(
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
        status: ItemStatus.recovered,
        createdAt: old.createdAt,
      );
      notifyListeners();
    }
  }

  Future<void> publishNotice(NoticeEntity notice) async {
    final created = await _noticeRepository.createNotice(notice);
    _notices.insert(0, created);
    notifyListeners();
  }
}
