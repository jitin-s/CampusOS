"""Deterministic and explainable matching rules for Lost & Found items.

Authoritative specification for TASK-2 / PHASE-2: SMART LOST & FOUND MATCHING.
Supports configurable scoring weights, transparent factor decomposition,
conflict detection, and human-readable explanation generation.
Zero ML black-boxes - strictly transparent, reproducible, and explainable.
"""

import re
from dataclasses import dataclass
from datetime import datetime
from typing import Dict, Tuple, List, Optional, Set, Any


@dataclass
class MatchWeights:
    """Configurable scoring weights for Lost & Found matching. Sums to 100.0."""
    category: float = 25.0
    item_type: float = 20.0
    brand: float = 15.0
    color: float = 15.0
    location: float = 10.0
    time: float = 10.0
    description: float = 5.0

    def total(self) -> float:
        return (
            self.category
            + self.item_type
            + self.brand
            + self.color
            + self.location
            + self.time
            + self.description
        )

    def validate(self) -> bool:
        """Verify weights sum approximately to 100."""
        return abs(self.total() - 100.0) < 0.1


# Backward compatibility constants
WEIGHT_CATEGORY = 30.0
WEIGHT_BRAND = 20.0
WEIGHT_COLOR = 15.0
WEIGHT_LOCATION = 15.0
WEIGHT_TIME = 10.0
WEIGHT_NAME_DESC = 10.0


# Category synonym dictionary for fuzzy compatible matching
CATEGORY_SYNONYMS: Dict[str, Set[str]] = {
    "electronics": {"electronics", "gadgets", "devices", "digital", "tech"},
    "personal": {"personal", "accessories", "belongings", "daily", "essentials"},
    "clothing": {"clothing", "apparel", "wear", "garments"},
    "documents": {"documents", "cards", "id", "id cards", "wallet", "purses"},
    "stationery": {"stationery", "books", "notebooks", "study", "academic"},
}


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


# ---------------------------------------------------------------------------
# Detailed Attribute Evaluators (Phase-2)
# ---------------------------------------------------------------------------

def evaluate_category_detailed(
    cat_a: Optional[str],
    cat_b: Optional[str],
    weight: float = 25.0,
) -> Tuple[float, bool, Optional[str], str]:
    """Evaluate category match with full explanation."""
    norm_a = normalize_text(cat_a)
    norm_b = normalize_text(cat_b)

    if not norm_a or not norm_b:
        return 0.0, False, None, "— Category not specified"

    if norm_a == norm_b:
        return weight, True, "category_match", f"✓ Category matches ({cat_a.strip()})"

    # Check synonym mapping
    for canonical, syns in CATEGORY_SYNONYMS.items():
        if norm_a in syns and norm_b in syns:
            score = round(weight * 0.8, 1)
            return score, True, "category_match", f"✓ Category is compatible ({cat_a.strip()} / {cat_b.strip()})"

    if norm_a in norm_b or norm_b in norm_a:
        score = round(weight * 0.75, 1)
        return score, True, "category_match", f"✓ Category partial match ({cat_a.strip()} / {cat_b.strip()})"

    return 0.0, False, None, f"✗ Category conflicts ({cat_a.strip()} vs {cat_b.strip()})"


def evaluate_item_type_detailed(
    type_a: Optional[str],
    type_b: Optional[str],
    weight: float = 20.0,
) -> Tuple[float, bool, Optional[str], str]:
    """Evaluate item type match with full explanation."""
    norm_a = normalize_text(type_a)
    norm_b = normalize_text(type_b)

    if not norm_a or not norm_b:
        return 0.0, False, None, "— Item type not specified"

    if norm_a == norm_b:
        return weight, True, "item_type_match", f"✓ Item type matches ({type_a.strip()})"

    # Token overlap or substring containment
    overlap = token_overlap_ratio(type_a, type_b)
    if norm_a in norm_b or norm_b in norm_a or overlap >= 0.5:
        score = round(weight * 0.85, 1)
        return score, True, "item_type_match", f"✓ Item type is compatible ({type_a.strip()} / {type_b.strip()})"

    if overlap > 0.0:
        score = round(weight * 0.5, 1)
        return score, True, "item_type_match", f"✓ Item type partial match ({type_a.strip()} / {type_b.strip()})"

    return 0.0, False, None, f"✗ Item type conflicts ({type_a.strip()} vs {type_b.strip()})"


def evaluate_brand_detailed(
    brand_a: Optional[str],
    brand_b: Optional[str],
    weight: float = 15.0,
) -> Tuple[float, bool, Optional[str], str]:
    """Evaluate brand match with full explanation and conflict detection."""
    norm_a = normalize_text(brand_a)
    norm_b = normalize_text(brand_b)

    if not norm_a or not norm_b:
        missing_side = "lost report" if not norm_a else "found report"
        return 0.0, False, None, f"— Brand not specified in {missing_side}"

    if norm_a == norm_b:
        return weight, True, "brand_match", f"✓ Brand matches ({brand_a.strip()})"

    if norm_a in norm_b or norm_b in norm_a:
        score = round(weight * 0.85, 1)
        return score, True, "brand_match", f"✓ Brand matches closely ({brand_a.strip()} / {brand_b.strip()})"

    return 0.0, False, None, f"✗ Brand conflicts ({brand_a.strip()} vs {brand_b.strip()})"


def evaluate_color_detailed(
    color_a: Optional[str],
    color_b: Optional[str],
    weight: float = 15.0,
) -> Tuple[float, bool, Optional[str], str]:
    """Evaluate color match with full explanation."""
    tokens_a = tokenize(color_a)
    tokens_b = tokenize(color_b)

    if not tokens_a or not tokens_b:
        return 0.0, False, None, "— Color not specified"

    if tokens_a == tokens_b:
        return weight, True, "color_match", f"✓ Color matches ({color_a.strip()})"

    overlap = tokens_a.intersection(tokens_b)
    if overlap:
        ratio = len(overlap) / max(len(tokens_a), len(tokens_b))
        score = round(weight * ratio, 1)
        overlap_str = ", ".join(overlap)
        return score, True, "color_match", f"✓ Color overlap on '{overlap_str}'"

    return 0.0, False, None, f"✗ Color differs ({color_a.strip()} vs {color_b.strip()})"


def evaluate_location_detailed(
    loc_a: Optional[str],
    loc_b: Optional[str],
    weight: float = 10.0,
) -> Tuple[float, bool, Optional[str], str]:
    """Evaluate location proximity with full explanation."""
    norm_a = normalize_text(loc_a)
    norm_b = normalize_text(loc_b)

    if not norm_a or not norm_b:
        return 0.0, False, None, "— Location not specified"

    if norm_a == norm_b:
        return weight, True, "location_proximity", f"✓ Location is nearby ({loc_a.strip()})"

    overlap_ratio = token_overlap_ratio(loc_a, loc_b)
    if norm_a in norm_b or norm_b in norm_a or overlap_ratio >= 0.5:
        score = round(weight * 0.9, 1)
        return score, True, "location_proximity", f"✓ Location is nearby ({loc_a.strip()} / {loc_b.strip()})"

    if overlap_ratio > 0.0:
        score = round(weight * 0.5, 1)
        return score, True, "location_proximity", f"✓ Location in same general zone ({loc_a.strip()})"

    return 0.0, False, None, f"✗ Location differs ({loc_a.strip()} vs {loc_b.strip()})"


def evaluate_time_proximity_detailed(
    time_a: Optional[str],
    time_b: Optional[str],
    weight: float = 10.0,
) -> Tuple[float, bool, Optional[str], str]:
    """Evaluate time proximity with full explanation."""
    dt_a = parse_timestamp(time_a)
    dt_b = parse_timestamp(time_b)

    if not dt_a or not dt_b:
        return 0.0, False, None, "— Time not specified"

    diff_seconds = abs((dt_a - dt_b).total_seconds())
    diff_days = diff_seconds / 86400.0
    diff_hours = diff_seconds / 3600.0

    if diff_hours <= 4.0:
        return weight, True, "time_proximity", f"✓ Time is very close (within {int(diff_hours)+1}h)"
    elif diff_days <= 1.0:
        score = round(weight * 0.85, 1)
        return score, True, "time_proximity", "✓ Time is similar (same day / within 24h)"
    elif diff_days <= 3.0:
        score = round(weight * 0.7, 1)
        return score, True, "time_proximity", f"✓ Time is similar (within {int(diff_days)} days)"
    elif diff_days <= 7.0:
        score = round(weight * 0.45, 1)
        return score, True, "time_proximity", "✓ Time within 1 week"
    elif diff_days <= 14.0:
        score = round(weight * 0.2, 1)
        return score, True, "time_proximity", "✓ Time within 2 weeks"

    return 0.0, False, None, f"✗ Time gap is large ({int(diff_days)} days apart)"


def evaluate_description_detailed(
    desc_a: Optional[str],
    desc_b: Optional[str],
    weight: float = 5.0,
) -> Tuple[float, bool, Optional[str], str]:
    """Evaluate free-text description similarity with full explanation."""
    ratio = token_overlap_ratio(desc_a, desc_b)
    if ratio >= 0.4:
        return weight, True, "description_similarity", "✓ Description details strongly corroborate match"
    elif ratio >= 0.15:
        score = round(weight * 0.6, 1)
        return score, True, "description_similarity", "✓ Description has matching keywords"
    elif ratio > 0.0:
        score = round(weight * 0.3, 1)
        return score, True, "description_similarity", "✓ Minor description keyword overlap"

    return 0.0, False, None, "— No distinctive description overlap"


# ---------------------------------------------------------------------------
# Backward Compatibility Adapters (Matches Phase-1 signatures)
# ---------------------------------------------------------------------------

def evaluate_category(cat_a: Optional[str], cat_b: Optional[str]) -> Tuple[float, bool]:
    score, matched, _, _ = evaluate_category_detailed(cat_a, cat_b, weight=WEIGHT_CATEGORY)
    return score, matched


def evaluate_brand(brand_a: Optional[str], brand_b: Optional[str]) -> Tuple[float, bool]:
    score, matched, _, _ = evaluate_brand_detailed(brand_a, brand_b, weight=WEIGHT_BRAND)
    return score, matched


def evaluate_color(color_a: Optional[str], color_b: Optional[str]) -> Tuple[float, bool]:
    score, matched, _, _ = evaluate_color_detailed(color_a, color_b, weight=WEIGHT_COLOR)
    return score, matched


def evaluate_location(loc_a: Optional[str], loc_b: Optional[str]) -> Tuple[float, bool]:
    score, matched, _, _ = evaluate_location_detailed(loc_a, loc_b, weight=WEIGHT_LOCATION)
    return score, matched


def evaluate_time_proximity(time_a: Optional[str], time_b: Optional[str]) -> Tuple[float, bool]:
    score, matched, _, _ = evaluate_time_proximity_detailed(time_a, time_b, weight=WEIGHT_TIME)
    return score, matched


def evaluate_name_and_description(
    name_a: str,
    desc_a: Optional[str],
    name_b: str,
    desc_b: Optional[str],
) -> Tuple[float, bool]:
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
