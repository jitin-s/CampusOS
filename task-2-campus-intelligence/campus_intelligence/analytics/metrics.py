"""Deterministic campus operational analytics and reliability formulas.

Formulas match Section 14 of docs/03_ARCHITECTURE.md:
- Recovery Rate = Recovered Items / Total Lost Items
- Resolution Rate = Resolved Issues / Total Issues
- Average Resolution Time = Average(resolved_at - created_at)
- Reliability Score = Weighted composite of resolution speed, recurrence, and backlog
"""

from typing import List, Dict, Any, Optional, Tuple
from datetime import datetime
from campus_intelligence.core.models import IssueRecord, LostItem, FoundItem, IssueCluster
from campus_intelligence.matching.rules import parse_timestamp


RESOLVED_STATUSES = {"resolved", "student_verified", "closed"}


def calculate_resolution_metrics(issues: List[IssueRecord]) -> Tuple[int, int, float, float]:
    """Calculate active count, resolved count, resolution rate (%), and average resolution time (hours)."""
    total = len(issues)
    if total == 0:
        return 0, 0, 100.0, 0.0

    resolved_count = 0
    total_duration_hours = 0.0
    duration_sample_count = 0

    for issue in issues:
        is_resolved = (issue.status.lower() in RESOLVED_STATUSES) or (issue.resolved_at is not None)
        if is_resolved:
            resolved_count += 1
            if issue.created_at and issue.resolved_at:
                t_start = parse_timestamp(issue.created_at)
                t_end = parse_timestamp(issue.resolved_at)
                if t_start and t_end and t_end >= t_start:
                    hours = (t_end - t_start).total_seconds() / 3600.0
                    total_duration_hours += hours
                    duration_sample_count += 1

    active_count = total - resolved_count
    resolution_rate = round((resolved_count / total) * 100.0, 1)

    avg_resolution_time = (
        round(total_duration_hours / duration_sample_count, 1)
        if duration_sample_count > 0
        else 0.0
    )

    return active_count, resolved_count, resolution_rate, avg_resolution_time


def calculate_recovery_rate(lost_items: List[LostItem], found_items: List[FoundItem]) -> float:
    """Calculate Lost & Found recovery percentage."""
    if not lost_items:
        return 0.0

    recovered_count = sum(
        1 for item in lost_items
        if str(item.metadata.get("status", "")).lower() == "recovered"
        or str(item.metadata.get("is_recovered", "")).lower() == "true"
    )
    return round((recovered_count / len(lost_items)) * 100.0, 1)


def compute_distributions(issues: List[IssueRecord]) -> Tuple[Dict[str, int], Dict[str, int], Dict[str, Dict[str, Any]]]:
    """Compute category, location, and department distributions."""
    category_counts: Dict[str, int] = {}
    location_counts: Dict[str, int] = {}
    dept_stats: Dict[str, Dict[str, Any]] = {}

    for issue in issues:
        cat = (issue.category or "other").lower()
        category_counts[cat] = category_counts.get(cat, 0) + 1

        loc = issue.location or "unspecified"
        location_counts[loc] = location_counts.get(loc, 0) + 1

        dept = issue.department or "General Administration"
        if dept not in dept_stats:
            dept_stats[dept] = {"total": 0, "resolved": 0, "active": 0}
        dept_stats[dept]["total"] += 1
        if issue.status.lower() in RESOLVED_STATUSES:
            dept_stats[dept]["resolved"] += 1
        else:
            dept_stats[dept]["active"] += 1

    return category_counts, location_counts, dept_stats


def calculate_campus_reliability_score(
    resolution_rate: float,
    active_critical_issues: int,
    recurring_clusters_count: int,
    avg_resolution_time_hours: float,
) -> float:
    """Calculate a 0-100% composite campus infrastructure reliability score.

    Base formula:
    - 60% weight from Resolution Rate
    - Resolution Speed bonus up to 20% (for under 24h average resolution)
    - Deductions:
      - 5% penalty per active critical issue (up to 15%)
      - 5% penalty per recurring problem cluster (up to 15%)
    """
    base_score = resolution_rate * 0.6

    speed_score = 20.0
    if avg_resolution_time_hours > 72:
        speed_score = 5.0
    elif avg_resolution_time_hours > 48:
        speed_score = 10.0
    elif avg_resolution_time_hours > 24:
        speed_score = 15.0

    penalties = (min(3, active_critical_issues) * 5.0) + (min(3, recurring_clusters_count) * 5.0)

    final_score = base_score + speed_score - penalties
    return round(min(100.0, max(0.0, final_score)), 1)
