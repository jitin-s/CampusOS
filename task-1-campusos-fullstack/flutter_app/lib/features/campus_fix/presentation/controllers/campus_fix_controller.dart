import 'package:flutter/foundation.dart';

import '../../../../domain/entities/issue_entity.dart';
import '../../../../domain/repositories/issue_repository.dart';

class CampusFixController extends ChangeNotifier {
  final IssueRepository _issueRepository;

  List<IssueEntity> _issues = [];
  bool _isLoading = false;
  String? _errorMessage;

  CampusFixController({required IssueRepository issueRepository})
    : _issueRepository = issueRepository;

  List<IssueEntity> get issues => _issues;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadIssues({
    required String campusId,
    String? reporterId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _issues = await _issueRepository.getIssues(
        campusId: campusId,
        reporterId: reporterId,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<IssueEntity?> reportIssue({
    required String campusId,
    required String reporterId,
    required String category,
    required String type,
    required String description,
    required String locationId,
    required IssueSeverity severity,
    String? beforeImageUrl,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newIssue = await _issueRepository.createIssue(
        campusId: campusId,
        reporterId: reporterId,
        category: category,
        type: type,
        description: description,
        locationId: locationId,
        severity: severity,
        beforeImageUrl: beforeImageUrl,
      );
      _issues.insert(0, newIssue);
      _isLoading = false;
      notifyListeners();
      return newIssue;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> verifyResolution(String issueId) async {
    try {
      final updated = await _issueRepository.updateStatus(
        issueId: issueId,
        newStatus: IssueStatus.studentVerified,
      );
      final index = _issues.indexWhere((e) => e.id == issueId);
      if (index != -1) {
        _issues[index] = updated;
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
