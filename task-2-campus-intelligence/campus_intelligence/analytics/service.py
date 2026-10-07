"""CampusOS Operational Analytics Service.

Implements IAnalyticsService for high-level campus intelligence dashboards.
"""

from typing import List, Dict, Any, Optional, Union
from campus_intelligence.core.interfaces import IAnalyticsService
from campus_intelligence.core.models import (
    IssueRecord,
    LostItem,
    FoundItem,
    IssueCluster,
    CampusAnalytics,
)
from campus_intelligence.analytics.metrics import (
    calculate_resolution_metrics,
    calculate_recovery_rate,
    compute_distributions,
    calculate_campus_reliability_score,
)
from campus_intelligence.clustering.service import ClusteringService


class AnalyticsService(IAnalyticsService):
    """Deterministic analytics computation service."""

    def __init__(self, clustering_service: Optional[ClusteringService] = None):
        self._clustering_service = clustering_service or ClusteringService()

    def calculate_campus_analytics(
        self,
        issues: List[Union[IssueRecord, Dict[str, Any]]],
        lost_items: List[Union[LostItem, Dict[str, Any]]],
        found_items: List[Union[FoundItem, Dict[str, Any]]],
        clusters: Optional[List[IssueCluster]] = None,
    ) -> CampusAnalytics:
        """Calculate aggregated operational metrics and reliability scores.

        Args:
            issues: List of issues.
            lost_items: List of lost items.
            found_items: List of found items.
            clusters: Pre-computed issue clusters (optional, calculated if omitted).

        Returns:
            CampusAnalytics data transfer object with full metric suite.
        """
        issue_records = [
            IssueRecord.from_dict(i) if isinstance(i, dict) else i
            for i in issues
        ]
        lost_records = [
            LostItem.from_dict(i) if isinstance(i, dict) else i
            for i in lost_items
        ]
        found_records = [
            FoundItem.from_dict(i) if isinstance(i, dict) else i
            for i in found_items
        ]

        active_cnt, resolved_cnt, res_rate, avg_res_time = calculate_resolution_metrics(issue_records)
        recovery_rate = calculate_recovery_rate(lost_records, found_records)
        cat_dist, loc_dist, dept_stats = compute_distributions(issue_records)

        if clusters is None:
            clusters = self._clustering_service.cluster_issues(issue_records)

        recurring_clusters = sum(1 for c in clusters if c.is_recurring)
        active_critical = sum(
            1 for i in issue_records
            if i.status.lower() not in {"resolved", "student_verified", "closed"}
            and (i.priority.upper() == "CRITICAL" or i.severity.lower() == "critical")
        )

        reliability_score = calculate_campus_reliability_score(
            resolution_rate=res_rate,
            active_critical_issues=active_critical,
            recurring_clusters_count=recurring_clusters,
            avg_resolution_time_hours=avg_res_time,
        )

        return CampusAnalytics(
            total_issues=len(issue_records),
            active_issues=active_cnt,
            resolved_issues=resolved_cnt,
            resolution_rate=res_rate,
            average_resolution_time_hours=avg_res_time,
            lost_found_recovery_rate=recovery_rate,
            category_distribution=cat_dist,
            location_distribution=loc_dist,
            department_performance=dept_stats,
            recurring_clusters_count=recurring_clusters,
            campus_reliability_score=reliability_score,
        )
