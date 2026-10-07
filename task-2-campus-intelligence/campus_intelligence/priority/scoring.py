"""Transparent and deterministic scoring rules for campus issue priority.

Uses explainable weighted points rather than a black-box model.
Calculates score (0-100) and maps to [LOW, MEDIUM, HIGH, CRITICAL].
"""

from typing import Dict, Tuple, List, Optional
from campus_intelligence.core.types import PriorityLevel


CRITICAL_LOCATIONS = {
    "exam hall",
    "examination hall",
    "server room",
    "data center",
    "substation",
    "power room",
    "auditorium",
    "main library",
    "medical room",
    "infirmary",
}

ACADEMIC_LOCATIONS = {
    "classroom",
    "lecture hall",
    "lab",
    "laboratory",
    "faculty room",
    "department office",
}


def score_severity(severity: Optional[str]) -> Tuple[int, str]:
    """Score base severity level (10 - 40 points)."""
    sev = (severity or "medium").lower().strip()
    if sev in ("critical", "emergency", "blocker", "4", "5"):
        return 40, "Critical severity (+40 pts)"
    elif sev in ("high", "major", "3"):
        return 30, "High severity (+30 pts)"
    elif sev in ("medium", "moderate", "normal", "2"):
        return 20, "Medium severity (+20 pts)"
    elif sev in ("low", "minor", "trivial", "1"):
        return 10, "Low severity (+10 pts)"
    return 15, "Standard severity (+15 pts)"


def score_location_criticality(location: Optional[str]) -> Tuple[int, str]:
    """Score location sensitivity and operational impact (0 - 20 points)."""
    if not location:
        return 5, "Unspecified location (+5 pts)"
    loc = location.lower().strip()

    for crit in CRITICAL_LOCATIONS:
        if crit in loc:
            return 20, f"Critical infrastructure location: '{location}' (+20 pts)"

    for acad in ACADEMIC_LOCATIONS:
        if acad in loc:
            return 12, f"Active academic learning space: '{location}' (+12 pts)"

    if "hostel" in loc or "dorm" in loc:
        return 10, f"Student residential facility: '{location}' (+10 pts)"

    return 5, f"General campus location: '{location}' (+5 pts)"


def score_affected_users(affected_users: int) -> Tuple[int, str]:
    """Score impact based on estimated population affected (0 - 20 points)."""
    try:
        users = int(affected_users)
    except (ValueError, TypeError):
        users = 1

    if users >= 100:
        return 20, f"Campus-wide / large impact: {users}+ affected users (+20 pts)"
    elif users >= 50:
        return 15, f"High classroom/floor impact: {users} affected users (+15 pts)"
    elif users >= 15:
        return 10, f"Group impact: {users} affected users (+10 pts)"
    elif users >= 2:
        return 5, f"Small cohort impact: {users} affected users (+5 pts)"
    return 0, "Single individual impact (+0 pts)"


def score_urgency(urgency: Optional[str]) -> Tuple[int, str]:
    """Score explicit urgency requirement (0 - 15 points)."""
    urg = (urgency or "medium").lower().strip()
    if urg in ("immediate", "critical", "emergency", "now"):
        return 15, "Immediate urgency declared (+15 pts)"
    elif urg in ("high", "today", "urgent"):
        return 10, "Same-day urgency declared (+10 pts)"
    elif urg in ("medium", "standard", "normal"):
        return 5, "Standard operational urgency (+5 pts)"
    return 0, "Low urgency (+0 pts)"


def score_recurrence(recurrence_count: int) -> Tuple[int, str]:
    """Score boost for repeated/recurring campus failures (0 - 10 points)."""
    try:
        count = int(recurrence_count)
    except (ValueError, TypeError):
        count = 1

    if count >= 3:
        return 10, f"High recurrence detected: failed {count} times (+10 pts)"
    elif count == 2:
        return 5, f"Recurring issue detected: reported {count} times (+5 pts)"
    return 0, "First occurrence (+0 pts)"


def map_score_to_priority(score: int) -> PriorityLevel:
    """Map final composite score (0-100) to PriorityLevel enum."""
    if score >= 75:
        return PriorityLevel.CRITICAL
    elif score >= 55:
        return PriorityLevel.HIGH
    elif score >= 35:
        return PriorityLevel.MEDIUM
    return PriorityLevel.LOW
