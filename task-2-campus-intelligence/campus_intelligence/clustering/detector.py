"""Campus issue clustering heuristics and grouping logic.

Groups issues by location, category, textual similarity, and temporal proximity.
Flags operational hotspots and recurring equipment failures.
"""

import re
from datetime import datetime
from typing import List, Dict, Any, Set, Optional, Tuple
from campus_intelligence.core.models import IssueRecord, IssueCluster
from campus_intelligence.matching.rules import parse_timestamp, tokenize, token_overlap_ratio


def normalize_location_key(location: Optional[str]) -> str:
    """Normalize campus location into canonical grouping key."""
    if not location:
        return "campus_general"
    loc = location.lower().strip()
    loc = re.sub(r"[-_]", " ", loc)
    # Common substitutions (e.g., 'rm 204' -> 'room 204')
    loc = re.sub(r"\brm\b", "room", loc)
    return " ".join(loc.split())


def are_locations_compatible(loc_a: str, loc_b: str) -> bool:
    """Check if two location strings refer to the same physical area."""
    key_a = normalize_location_key(loc_a)
    key_b = normalize_location_key(loc_b)
    if key_a == key_b:
        return True
    if key_a in key_b or key_b in key_a:
        return True
    return token_overlap_ratio(key_a, key_b) >= 0.5


def are_issues_similar(issue_a: IssueRecord, issue_b: IssueRecord, similarity_threshold: float = 0.4) -> bool:
    """Evaluate whether two issues represent the same recurring underlying failure."""
    # Must share either same category or compatible location
    loc_match = are_locations_compatible(issue_a.location, issue_b.location)
    cat_match = (issue_a.category.lower() == issue_b.category.lower())

    if not (loc_match or cat_match):
        return False

    text_a = f"{issue_a.title} {issue_a.description or ''}"
    text_b = f"{issue_b.title} {issue_b.description or ''}"
    text_similarity = token_overlap_ratio(text_a, text_b)

    # If exact same location and category, lower text threshold is sufficient
    if loc_match and cat_match:
        return True

    # If same location and high text similarity
    if loc_match and text_similarity >= 0.3:
        return True

    # If same category and very high text similarity across nearby locations
    if cat_match and text_similarity >= similarity_threshold:
        return True

    return False


def build_cluster_topic(category: str, location: str, issues: List[IssueRecord]) -> str:
    """Generate a clean, human-readable topic name for the problem cluster."""
    count = len(issues)
    cat_title = category.replace("_", " ").title()
    loc_title = location.title() if location else "Campus"

    # Check for specific equipment / keyword commonalities
    sample_texts = " ".join([i.title.lower() for i in issues])
    if "projector" in sample_texts:
        return f"Recurring Projector Issues in {loc_title} ({count} reports)"
    elif "wifi" in sample_texts or "internet" in sample_texts:
        return f"Possible Network / Wi-Fi Outage in {loc_title} ({count} reports)"
    elif "water" in sample_texts or "leak" in sample_texts:
        return f"Water Supply / Plumbing Fault in {loc_title} ({count} reports)"
    elif "power" in sample_texts or "socket" in sample_texts:
        return f"Electrical Outage / Power Fault in {loc_title} ({count} reports)"

    return f"Recurring {cat_title} Failures in {loc_title} ({count} reports)"
