import 'package:uuid/uuid.dart';

import '../../core/network/supabase_client_manager.dart';
import '../../domain/entities/issue_entity.dart';
import '../../domain/repositories/issue_repository.dart';
import '../models/issue_model.dart';

class SupabaseIssueRepository implements IssueRepository {
  final SupabaseClientManager _clientManager;
  final List<IssueEntity> _mockIssues = [];

  SupabaseIssueRepository({SupabaseClientManager? clientManager})
    : _clientManager = clientManager ?? SupabaseClientManager.instance {
    _initMockData();
  }

  void _initMockData() {
    _mockIssues.addAll([
      IssueModel(
        id: 'issue-1042',
        campusId: 'campus-alpha-001',
        reporterId: 'mock-user-123',
        category: 'Equipment',
        type: 'Projector',
        description: 'The projector in Room 204 is not displaying output and has a blinking red lamp.',
        locationId: 'Room 204',
        severity: IssueSeverity.high,
        departmentId: 'IT Support',
        assignedTo: 'Rajesh Technician',
        status: IssueStatus.inProgress,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      IssueModel(
        id: 'issue-1043',
        campusId: 'campus-alpha-001',
        reporterId: 'mock-user-123',
        category: 'Electrical',
        type: 'Power Outlet',
        description: 'Sparks observed from wall socket near desk 4.',
        locationId: 'Library 2nd Floor',
        severity: IssueSeverity.critical,
        departmentId: 'Facilities',
        assignedTo: 'Electrical Team',
        status: IssueStatus.assigned,
        createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
      ),
      IssueModel(
        id: 'issue-1040',
        campusId: 'campus-alpha-001',
        reporterId: 'mock-user-123',
        category: 'Cleanliness',
        type: 'Water Leak',
        description: 'Drinking water dispenser tray overflowing on corridor.',
        locationId: 'Block A Floor 1',
        severity: IssueSeverity.medium,
        departmentId: 'Maintenance',
        assignedTo: 'Sanitation Staff',
        status: IssueStatus.resolved,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        resolvedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ]);
  }

  @override
  Future<List<IssueEntity>> getIssues({
    required String campusId,
    String? reporterId,
    IssueStatus? status,
  }) async {
    final client = _clientManager.client;
    if (client != null) {
      var query = client.from('issues').select().eq('campus_id', campusId);
      if (reporterId != null) {
        query = query.eq('reporter_id', reporterId);
      }
      if (status != null) {
        query = query.eq('status', status.toDbValue());
      }
      final response = await query.order('created_at', ascending: false);
      return (response as List)
          .map((item) => IssueModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // Mock fallback
    await Future.delayed(const Duration(milliseconds: 150));
    var results = _mockIssues.where((e) => e.campusId == campusId);
    if (reporterId != null) {
      results = results.where((e) => e.reporterId == reporterId);
    }
    if (status != null) {
      results = results.where((e) => e.status == status);
    }
    return results.toList();
  }

  @override
  Future<IssueEntity> getIssueById(String id) async {
    final client = _clientManager.client;
    if (client != null) {
      final response = await client
          .from('issues')
          .select()
          .eq('id', id)
          .single();
      return IssueModel.fromJson(response);
    }

    await Future.delayed(const Duration(milliseconds: 100));
    return _mockIssues.firstWhere((e) => e.id == id);
  }

  @override
  Future<IssueEntity> createIssue({
    required String campusId,
    required String reporterId,
    required String category,
    required String type,
    required String description,
    required String locationId,
    required IssueSeverity severity,
    String? beforeImageUrl,
  }) async {
    final newId = 'issue-${const Uuid().v4().substring(0, 6)}';
    final issue = IssueModel(
      id: newId,
      campusId: campusId,
      reporterId: reporterId,
      category: category,
      type: type,
      description: description,
      locationId: locationId,
      severity: severity,
      status: IssueStatus.reported,
      beforeImageUrl: beforeImageUrl,
      createdAt: DateTime.now(),
    );

    final client = _clientManager.client;
    if (client != null) {
      await client.from('issues').insert(issue.toJson());
      return issue;
    }

    await Future.delayed(const Duration(milliseconds: 200));
    _mockIssues.insert(0, issue);
    return issue;
  }

  @override
  Future<IssueEntity> updateStatus({
    required String issueId,
    required IssueStatus newStatus,
    String? afterImageUrl,
  }) async {
    final client = _clientManager.client;
    if (client != null) {
      final updateData = <String, dynamic>{'status': newStatus.toDbValue()};
      if (afterImageUrl != null) {
        updateData['after_image_url'] = afterImageUrl;
      }
      if (newStatus == IssueStatus.resolved) {
        updateData['resolved_at'] = DateTime.now().toIso8601String();
      } else if (newStatus == IssueStatus.studentVerified) {
        updateData['verified_at'] = DateTime.now().toIso8601String();
      }
      final response = await client
          .from('issues')
          .update(updateData)
          .eq('id', issueId)
          .select()
          .single();
      return IssueModel.fromJson(response);
    }

    await Future.delayed(const Duration(milliseconds: 150));
    final index = _mockIssues.indexWhere((e) => e.id == issueId);
    if (index != -1) {
      final old = _mockIssues[index];
      final updated = IssueModel(
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
        afterImageUrl: afterImageUrl ?? old.afterImageUrl,
        createdAt: old.createdAt,
        resolvedAt: newStatus == IssueStatus.resolved
            ? DateTime.now()
            : old.resolvedAt,
        verifiedAt: newStatus == IssueStatus.studentVerified
            ? DateTime.now()
            : old.verifiedAt,
      );
      _mockIssues[index] = updated;
      return updated;
    }
    throw Exception('Issue not found: $issueId');
  }

  @override
  Future<IssueEntity> assignIssue({
    required String issueId,
    required String departmentId,
    required String assignedTo,
  }) async {
    final client = _clientManager.client;
    if (client != null) {
      final response = await client
          .from('issues')
          .update({
            'department_id': departmentId,
            'assigned_to': assignedTo,
            'status': IssueStatus.assigned.toDbValue(),
          })
          .eq('id', issueId)
          .select()
          .single();
      return IssueModel.fromJson(response);
    }

    await Future.delayed(const Duration(milliseconds: 150));
    final index = _mockIssues.indexWhere((e) => e.id == issueId);
    if (index != -1) {
      final old = _mockIssues[index];
      final updated = IssueModel(
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
      _mockIssues[index] = updated;
      return updated;
    }
    throw Exception('Issue not found: $issueId');
  }
}
