"""CampusOS Issue Clustering Service.

Implements IClusteringService for detecting recurring campus problems and operational hotspots.
"""

from typing import List, Dict, Any, Union
from datetime import datetime
from campus_intelligence.core.interfaces import IClusteringService
from campus_intelligence.core.models import IssueRecord, IssueCluster
from campus_intelligence.matching.rules import parse_timestamp
from campus_intelligence.clustering.detector import (
    normalize_location_key,
    are_issues_similar,
    build_cluster_topic,
)


class ClusteringService(IClusteringService):
    """Deterministic issue clustering service."""

    def cluster_issues(
        self,
        issues: List[Union[IssueRecord, Dict[str, Any]]],
        time_window_hours: int = 72,
        similarity_threshold: float = 0.4,
    ) -> List[IssueCluster]:
        """Group similar or recurring issues into clusters.

        Args:
            issues: List of IssueRecord instances or dictionaries.
            time_window_hours: Maximum hours between events to group together.
            similarity_threshold: Minimum textual similarity ratio.

        Returns:
            List of detected IssueCluster instances (containing 2 or more related issues).
        """
        # Convert dictionaries to IssueRecord objects if needed
        records = [
            IssueRecord.from_dict(i) if isinstance(i, dict) else i
            for i in issues
        ]

        if not records:
            return []

        # Sort by creation time if available
        records_sorted = sorted(
            records,
            key=lambda r: parse_timestamp(r.created_at) or datetime.min,
        )

        visited = set()
        clusters: List[IssueCluster] = []
        cluster_counter = 1

        for i, current in enumerate(records_sorted):
            if current.id in visited:
                continue

            current_group = [current]
            visited.add(current.id)

            current_time = parse_timestamp(current.created_at)

            for j in range(i + 1, len(records_sorted)):
                candidate = records_sorted[j]
                if candidate.id in visited:
                    continue

                candidate_time = parse_timestamp(candidate.created_at)

                # Check time window if both timestamps exist
                if current_time and candidate_time:
                    diff_hours = abs((candidate_time - current_time).total_seconds()) / 3600.0
                    if diff_hours > time_window_hours:
                        continue

                # Check issue similarity
                if are_issues_similar(current, candidate, similarity_threshold=similarity_threshold):
                    current_group.append(candidate)
                    visited.add(candidate.id)

            # If 2 or more issues are grouped, form a recognized cluster
            if len(current_group) >= 2:
                issue_ids = [rec.id for rec in current_group]
                loc = current_group[0].location
                cat = current_group[0].category
                topic = build_cluster_topic(cat, loc, current_group)
                is_recurring = len(current_group) >= 3

                # Determine cluster severity
                severities = [rec.severity.lower() for rec in current_group]
                if "critical" in severities or len(current_group) >= 4:
                    cluster_sev = "CRITICAL"
                elif "high" in severities or len(current_group) >= 3:
                    cluster_sev = "HIGH"
                else:
                    cluster_sev = "MEDIUM"

                timestamps = [
                    rec.created_at
                    for rec in current_group
                    if rec.created_at
                ]

                clusters.append(
                    IssueCluster(
                        cluster_id=f"cluster-{cluster_counter:03d}",
                        topic=topic,
                        location=loc,
                        primary_category=cat,
                        issue_count=len(current_group),
                        issue_ids=issue_ids,
                        is_recurring=is_recurring,
                        severity_level=cluster_sev,
                        earliest_issue_at=timestamps[0] if timestamps else None,
                        latest_issue_at=timestamps[-1] if timestamps else None,
                    )
                )
                cluster_counter += 1

        return clusters
