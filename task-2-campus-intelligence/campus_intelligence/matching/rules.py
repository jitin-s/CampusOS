"""Deterministic and explainable matching rules for Lost & Found items.

Computes weighted factor breakdown and explainable match attributes.
Zero ML black boxes - strictly transparent and reproducible.
"""

import re
from datetime import datetime
from typing import Dict, Tuple, List, Optional, Set


# Standard weights summing to 100
WEIGHT_CATEGORY = 30.0
WEIGHT_BRAND = 20.0
WEIGHT_COLOR = 15.0
WEIGHT_LOCATION = 15.0
WEIGHT_TIME = 10.0
WEIGHT_NAME_DESC = 10.0


def normalize_text(text: Optional[str]) -> str:
    """Normalize text for consistent comparison: lowercase, strip, single spaces."""
    if not text:
        return ""
    text = text.lower().strip()
    text = re.sub(r"[^\w\s]", " ", text)
    return " ".join(text.split())


def tokenize(text: Optional[str]) -> Set[str]:
    """Tokenize text into unique words, ignoring 1-letter stop words."""
    norm = normalize_text(text)
    if not norm:
        return set()
    return {w for w in norm.split() if len(w) > 1}


def token_overlap_ratio(text_a: Optional[str], text_b: Optional[str]) -> float:
    """Compute Jaccard token overlap between two strings."""
    tokens_a = tokenize(text_a)
    tokens_b = tokenize(text_b)
    if not tokens_a or not tokens_b:
        return 0.0
    intersection = tokens_a.intersection(tokens_b)
    union = tokens_a.union(tokens_b)
    return len(intersection) / len(union)


def evaluate_category(cat_a: Optional[str], cat_b: Optional[str]) -> Tuple[float, bool]:
    """Evaluate category match (30 max pts)."""
    norm_a = normalize_text(cat_a)
    norm_b = normalize_text(cat_b)
    if not norm_a or not norm_b:
        return 0.0, False
    if norm_a == norm_b:
        return WEIGHT_CATEGORY, True
    # Sub-string or partial category match (e.g. 'electronics' and 'laptop')
    if norm_a in norm_b or norm_b in norm_a:
        return WEIGHT_CATEGORY * 0.7, True
    return 0.0, False


def evaluate_brand(brand_a: Optional[str], brand_b: Optional[str]) -> Tuple[float, bool]:
    """Evaluate brand match (20 max pts)."""
    norm_a = normalize_text(brand_a)
    norm_b = normalize_text(brand_b)
    if not norm_a or not norm_b:
        # If brand is omitted on either side, no points, but not penalized
        return 0.0, False
    if norm_a == norm_b:
        return WEIGHT_BRAND, True
    if norm_a in norm_b or norm_b in norm_a:
        return WEIGHT_BRAND * 0.8, True
    return 0.0, False


def evaluate_color(color_a: Optional[str], color_b: Optional[str]) -> Tuple[float, bool]:
    """Evaluate color match (15 max pts)."""
    tokens_a = tokenize(color_a)
    tokens_b = tokenize(color_b)
    if not tokens_a or not tokens_b:
        return 0.0, False
    overlap = tokens_a.intersection(tokens_b)
    if overlap:
        # Exact or partial color match
        ratio = len(overlap) / max(len(tokens_a), len(tokens_b))
        score = WEIGHT_COLOR * ratio
        return round(score, 1), True
    return 0.0, False


def evaluate_location(loc_a: Optional[str], loc_b: Optional[str]) -> Tuple[float, bool]:
    """Evaluate location proximity / string match (15 max pts)."""
    norm_a = normalize_text(loc_a)
    norm_b = normalize_text(loc_b)
    if not norm_a or not norm_b:
        return 0.0, False
    if norm_a == norm_b:
        return WEIGHT_LOCATION, True
    overlap_ratio = token_overlap_ratio(loc_a, loc_b)
    if overlap_ratio >= 0.5:
        return round(WEIGHT_LOCATION * 0.9, 1), True
    if overlap_ratio > 0.0:
        return round(WEIGHT_LOCATION * 0.5, 1), True
    return 0.0, False


def parse_timestamp(ts: Optional[str]) -> Optional[datetime]:
    """Parse various timestamp formats safely."""
    if not ts:
        return None
    for fmt in (
        "%Y-%m-%dT%H:%M:%S",
        "%Y-%m-%dT%H:%M:%SZ",
        "%Y-%m-%d %H:%M:%S",
        "%Y-%m-%d",
    ):
        try:
            return datetime.strptime(ts.split("+")[0].rstrip("Z"), fmt)
        except (ValueError, TypeError):
            continue
    return None


def evaluate_time_proximity(time_a: Optional[str], time_b: Optional[str]) -> Tuple[float, bool]:
    """Evaluate time proximity between occurrences (10 max pts)."""
    dt_a = parse_timestamp(time_a)
    dt_b = parse_timestamp(time_b)
    if not dt_a or not dt_b:
        return 0.0, False
    diff_days = abs((dt_a - dt_b).total_seconds()) / 86400.0
    if diff_days <= 1.0:
        return WEIGHT_TIME, True
    elif diff_days <= 3.0:
        return round(WEIGHT_TIME * 0.75, 1), True
    elif diff_days <= 7.0:
        return round(WEIGHT_TIME * 0.5, 1), True
    elif diff_days <= 14.0:
        return round(WEIGHT_TIME * 0.25, 1), True
    return 0.0, False


def evaluate_name_and_description(
    name_a: str,
    desc_a: Optional[str],
    name_b: str,
    desc_b: Optional[str],
) -> Tuple[float, bool]:
    """Evaluate textual similarity between items (10 max pts)."""
    text_a = f"{name_a} {desc_a or ''}"
    text_b = f"{name_b} {desc_b or ''}"
    ratio = token_overlap_ratio(text_a, text_b)
    if ratio >= 0.5:
        return WEIGHT_NAME_DESC, True
    elif ratio >= 0.2:
        return round(WEIGHT_NAME_DESC * (ratio / 0.5), 1), True
    elif ratio > 0.0:
        return round(WEIGHT_NAME_DESC * 0.25, 1), True
    return 0.0, False
