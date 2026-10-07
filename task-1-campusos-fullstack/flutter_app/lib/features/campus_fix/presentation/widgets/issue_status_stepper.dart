import 'package:flutter/material.dart';

import '../../../../domain/entities/issue_entity.dart';

class IssueStatusStepper extends StatelessWidget {
  final IssueStatus currentStatus;

  const IssueStatusStepper({super.key, required this.currentStatus});

  static const List<IssueStatus> _orderedSteps = [
    IssueStatus.reported,
    IssueStatus.verified,
    IssueStatus.assigned,
    IssueStatus.inProgress,
    IssueStatus.resolved,
    IssueStatus.studentVerified,
  ];

  static const Map<IssueStatus, String> _stepLabels = {
    IssueStatus.reported: 'Reported',
    IssueStatus.verified: 'Verified',
    IssueStatus.assigned: 'Assigned',
    IssueStatus.inProgress: 'In Progress',
    IssueStatus.resolved: 'Resolved',
    IssueStatus.studentVerified: 'Verified & Closed',
  };

  int get _currentIndex {
    final idx = _orderedSteps.indexOf(currentStatus);
    return idx == -1 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _orderedSteps.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i <= _currentIndex
                          ? const Color(0xFF16A34A)
                          : Colors.grey[300],
                      border: Border.all(
                        color: i <= _currentIndex
                            ? const Color(0xFF16A34A)
                            : Colors.grey[400]!,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: i <= _currentIndex
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                    ),
                  ),
                  if (i < _orderedSteps.length - 1)
                    Container(
                      width: 2,
                      height: 28,
                      color: i < _currentIndex
                          ? const Color(0xFF16A34A)
                          : Colors.grey[300],
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    _stepLabels[_orderedSteps[i]] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: i == _currentIndex
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: i <= _currentIndex
                          ? Colors.black87
                          : Colors.grey[500],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
