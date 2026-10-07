"""CampusOS Intelligence Engine - Shared Enums and Constants.

Authoritative specification based on:
- docs/01_PRD.md
- docs/02_SRD.md
- docs/03_ARCHITECTURE.md
"""

from enum import Enum


class PriorityLevel(str, Enum):
    """Priority levels for campus issues."""
    LOW = "LOW"
    MEDIUM = "MEDIUM"
    HIGH = "HIGH"
    CRITICAL = "CRITICAL"


class MatchConfidence(str, Enum):
    """Confidence ratings for Lost & Found item matching."""
    NONE = "none"
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    VERY_HIGH = "very_high"


class IssueCategory(str, Enum):
    """Standard CampusFix categories per SRD / UX specifications."""
    CLASSROOM = "classroom"
    ELECTRICAL = "electrical"
    WIFI = "wifi"
    EQUIPMENT = "equipment"
    CLEANLINESS = "cleanliness"
    WATER = "water"
    HOSTEL = "hostel"
    OTHER = "other"


class CampusDepartment(str, Enum):
    """Responsible campus administrative and maintenance departments."""
    IT = "IT"
    ELECTRICAL = "Electrical Maintenance"
    ESTATE = "Estate & Civil"
    SANITATION = "Sanitation & Housekeeping"
    HOSTEL = "Hostel Administration"
    ACADEMIC = "Academic Affairs"
    SECURITY = "Campus Security"
    GENERAL = "General Administration"


class IssueStatus(str, Enum):
    """Lifecycle status for campus issues."""
    REPORTED = "reported"
    VERIFIED = "verified"
    ASSIGNED = "assigned"
    IN_PROGRESS = "in_progress"
    RESOLVED = "resolved"
    STUDENT_VERIFIED = "student_verified"
    CLOSED = "closed"
