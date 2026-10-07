"""CampusOS Issue Priority Evaluation Service.

Implements IPriorityService with transparent, deterministic factor calculation.
Outputs explainable priority scores and ratings for admin triage.
"""

from typing import List, Dict, Any, Union
from campus_intelligence.core.interfaces import IPriorityService
from campus_intelligence.core.models import PriorityResult
from campus_intelligence.core.types import PriorityLevel
from campus_intelligence.priority.scoring import (
    score_severity,
    score_location_criticality,
    score_affected_users,
    score_urgency,
    score_recurrence,
    map_score_to_priority,
)


class PriorityService(IPriorityService):
    """Deterministic, explainable priority scoring service."""

    def calculate_priority(
        self,
        category: str,
        severity: str,
        location: str,
        affected_users: int = 1,
        urgency: str = "medium",
        recurrence_count: int = 1,
    ) -> PriorityResult:
        """Calculate explainable priority score and level for an issue.

        Args:
            category: Issue category (e.g., 'electrical', 'wifi', 'equipment').
            severity: Declared or assessed severity ('low', 'medium', 'high', 'critical').
            location: Campus location of the issue.
            affected_users: Estimated number of people affected.
            urgency: Time-sensitivity assessment ('low', 'medium', 'high', 'immediate').
            recurrence_count: Times this failure pattern has occurred recently.

        Returns:
            PriorityResult with priority enum (LOW, MEDIUM, HIGH, CRITICAL), score, and explanations.
        """
        explanation: List[str] = []
        breakdown: Dict[str, int] = {}

        # 1. Base Severity (10 - 40 pts)
        sev_pts, sev_exp = score_severity(severity)
        breakdown["severity"] = sev_pts
        explanation.append(sev_exp)

        # 2. Location Criticality (0 - 20 pts)
        loc_pts, loc_exp = score_location_criticality(location)
        breakdown["location"] = loc_pts
        explanation.append(loc_exp)

        # 3. Affected Population Impact (0 - 20 pts)
        pop_pts, pop_exp = score_affected_users(affected_users)
        breakdown["affected_users"] = pop_pts
        explanation.append(pop_exp)

        # 4. Urgency Factor (0 - 15 pts)
        urg_pts, urg_exp = score_urgency(urgency)
        breakdown["urgency"] = urg_pts
        explanation.append(urg_exp)

        # 5. Recurrence Boost (0 - 10 pts)
        rec_pts, rec_exp = score_recurrence(recurrence_count)
        breakdown["recurrence"] = rec_pts
        if rec_pts > 0:
            explanation.append(rec_exp)

        # Composite total clamped to [0, 100]
        total_score = min(100, max(0, sum(breakdown.values())))
        priority_level = map_score_to_priority(total_score)

        return PriorityResult(
            priority=priority_level.value,
            score=total_score,
            explanation=explanation,
            breakdown=breakdown,
        )
