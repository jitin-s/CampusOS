# CampusOS — Campus Intelligence Engine (`task-2-campus-intelligence`)

**Owner:** Kartike (Task-2 Lead)\
**Current Phase:** Phase 2 — Smart Lost & Found Matching\
**Status:** Authoritative Foundation & Smart Matching Engine Complete & Tested (36/36 Unit Tests Passing)

---

## 1. Overview & Purpose

The Campus Intelligence Engine provides deterministic, explainable, and lightweight intelligence capabilities for CampusOS without introducing black-box ML models, external cloud dependencies, or heavy infrastructure.

In **Phase-2: Smart Lost & Found Matching**, we implement an explainable deterministic matching engine that pairs student lost reports with found items based on configurable weighted criteria, detects explicit conflicts, and outputs human-readable verification explanations.

---

## 2. Architecture & Directory Layout

The module strictly follows the architecture defined in `docs/02_SRD.md` and `docs/03_ARCHITECTURE.md`:

```
task-2-campus-intelligence/
├── campus_intelligence/
│   ├── core/
│   │   ├── types.py          # Enums (PriorityLevel, MatchConfidence, IssueCategory, etc.)
│   │   ├── models.py         # DTOs (LostItem, FoundItem, MatchResult, IssueRecord, etc.)
│   │   └── interfaces.py      # Abstract Base Classes (IMatchingService, etc.)
│   ├── matching/             # Smart Lost & Found Matching Subsystem (Phase-2)
│   │   ├── rules.py          # Configurable MatchWeights, attribute evaluators & explanations
│   │   ├── service.py        # MatchingService implementing IMatchingService
│   │   └── demo_data.py      # Curated campus demo datasets for Lost & Found
│   ├── classification/       # Issue Classification & Routing Subsystem (Phase-1)
│   │   ├── rules.py          # Keyword taxonomy & location heuristics
│   │   └── service.py        # ClassificationService
│   ├── priority/             # Priority Evaluation Subsystem (Phase-1)
│   │   ├── scoring.py        # Transparent point formulas & clamp logic
│   │   └── service.py        # PriorityService
│   ├── clustering/           # Problem Clustering Subsystem (Phase-1)
│   │   ├── detector.py       # Spatio-temporal heuristics & topic generation
│   │   └── service.py        # ClusteringService
│   ├── analytics/            # Operational Analytics Subsystem (Phase-1)
│   │   ├── metrics.py        # SLA, resolution rates & campus reliability formulas
│   │   └── service.py        # AnalyticsService
│   └── cli.py                # Unified JSON CLI with --report text formatting
├── tests/                    # 36 comprehensive unit tests (100% pass)
│   ├── test_smart_matching.py # Phase-2 Smart Matching test suite (6 scenarios)
│   ├── test_matching.py       # Phase-1 baseline matching tests
│   ├── test_classification.py # Phase-1 classification tests
│   ├── test_priority.py       # Phase-1 priority tests
│   ├── test_clustering.py     # Phase-1 clustering tests
│   ├── test_analytics.py      # Phase-1 analytics tests
│   └── test_edge_cases.py     # Phase-1 boundary and error handling tests
└── pyproject.toml
```

---

## 3. Smart Matching Engine (Phase-2)

### 3.1 Algorithm & Scoring Breakdown

The engine evaluates 7 distinct dimensions with configurable weights summing to 100 points:

| Dimension | Default Weight | Matching Heuristic | Explanation Format |
|---|:---:|---|---|
| **Category** | 25.0 | Exact match, synonym taxonomy (`electronics`/`gadgets`), or partial | `✓ Category matches (Electronics)` |
| **Item Type** | 20.0 | Exact or token overlap (e.g. `Scientific Calculator` vs `Calculator`) | `✓ Item type matches (Scientific Calculator)` |
| **Brand** | 15.0 | Exact name, alias containment, conflict detection (`Apple` vs `Dell`) | `✓ Brand matches (Casio)` or `✗ Brand conflicts` |
| **Color** | 15.0 | Exact color, multi-color intersection (`Black and Silver` vs `Black`) | `✓ Color matches (Black)` or `✗ Color differs` |
| **Location** | 10.0 | Same room/venue, spatial token overlap, or same campus zone | `✓ Location is nearby (Central Library)` |
| **Time Proximity** | 10.0 | $\le 4\text{h}$ (100%), $\le 24\text{h}$ (85%), $\le 3\text{d}$ (70%), $\le 7\text{d}$ (45%) | `✓ Time is very close (within 2h)` |
| **Description** | 5.0 | Jaccard token overlap of distinctive descriptors and keywords | `✓ Description details corroborate match` |

#### Conflict Detection & Hard Guards:
- **Category & Type Mismatch Guard:** If both Category and Item Type completely conflict (e.g., *Umbrella* vs. *Laptop*), the maximum possible score is clamped to **15.0 points** regardless of location or time.
- **Brand Conflict Penalty:** If both items explicitly specify brands and they conflict (e.g., *Apple* vs. *Dell* or *Casio* vs. *Texas Instruments*), a **15.0-point penalty** is subtracted and recommendation is capped.

---

### 3.2 Output Recommendation & Confidence Tiers

| Score Range | Recommendation | Confidence Rating |
|:---:|:---:|:---:|
| **80 – 100** | `STRONG MATCH` | `HIGH CONFIDENCE` / `VERY HIGH` |
| **60 – 79** | `POTENTIAL MATCH` | `HIGH CONFIDENCE` / `MEDIUM` |
| **40 – 59** | `POSSIBLE MATCH` | `MEDIUM CONFIDENCE` |
| **20 – 39** | `WEAK MATCH` | `LOW CONFIDENCE` |
| **0 – 19** | `NO MATCH` | `NO CONFIDENCE` |

---

### 3.3 Public Interface (`IMatchingService`)

```python
from campus_intelligence import MatchingService, MatchWeights, LostItem, FoundItem

# Initialize service with default or custom weights
service = MatchingService(default_weights=MatchWeights())

# 1. Calculate match between Lost and Found items
result = service.calculate_match(lost_item, found_item, threshold=50)

# 2. Rank candidates from candidate pool
ranked_matches = service.find_matches_for_lost(lost_item, found_items, limit=5)

# 3. Format human-readable text report
text_report = MatchingService.format_explanation_report(result)
```

---

### 3.4 Sample Outputs

#### Example A: Exact Match (Casio Calculator in Library)

**Formatted Human-Readable Explanation:**
```text
95% — VERY HIGH CONFIDENCE

✓ Category matches (Electronics)
✓ Item type matches (Scientific Calculator)
✓ Brand matches (Casio)
✓ Color matches (Black)
✓ Location is nearby (Central Library 2nd Floor)
✓ Time is very close (within 1h)
✓ Description details strongly corroborate match

Recommendation:
STRONG MATCH
```

**JSON Output Structure (`MatchResult`):**
```json
{
  "score": 95,
  "confidence": "very_high",
  "recommendation": "STRONG MATCH",
  "factors": [
    "category_match",
    "item_type_match",
    "brand_match",
    "color_match",
    "location_proximity",
    "time_proximity",
    "description_similarity"
  ],
  "breakdown": {
    "category": 25.0,
    "item_type": 20.0,
    "brand": 15.0,
    "color": 15.0,
    "location": 10.0,
    "time": 10.0,
    "description": 5.0
  },
  "is_match": true,
  "factor_scores": {
    "category": 25.0,
    "item_type": 20.0,
    "brand": 15.0,
    "color": 15.0,
    "location": 10.0,
    "time": 10.0,
    "description": 5.0
  },
  "matching_factors": [
    "category_match",
    "item_type_match",
    "brand_match",
    "color_match",
    "location_proximity",
    "time_proximity",
    "description_similarity"
  ],
  "human_readable_explanation": [
    "✓ Category matches (Electronics)",
    "✓ Item type matches (Scientific Calculator)",
    "✓ Brand matches (Casio)",
    "✓ Color matches (Black)",
    "✓ Location is nearby (Central Library 2nd Floor)",
    "✓ Time is very close (within 1h)",
    "✓ Description details strongly corroborate match"
  ],
  "lost_item_id": "lost-001",
  "found_item_id": "found-001"
}
```

#### Example B: Conflicting Information (iPhone vs. Dell Charger)
```text
30% — LOW CONFIDENCE

✓ Category matches (Electronics)
✗ Item type conflicts (Phone vs Charger)
✗ Brand conflicts (Apple vs Dell)
✗ Color differs (Purple vs Black)
✓ Location is nearby (Lecture Hall 3)
✓ Time is very close (within 1h)
— No distinctive description overlap

Recommendation:
NO MATCH
```

---

## 4. Test Scenarios (36 / 36 Passing)

The test suite in [`tests/test_smart_matching.py`](file:///d:/CampusOS/CampusOS/task-2-campus-intelligence/tests/test_smart_matching.py) validates the 6 required scenarios:

1. **Exact match:** Casio fx-991EX Calculator lost in Library vs. found in Library ($\ge 90\%$, `STRONG MATCH`).
2. **Strong partial match:** Apple MacBook Air Silver in B204 lost 1.8 days before found report ($80-94\%$, `STRONG MATCH`).
3. **Weak match:** Personal Water Bottle with unknown brand and 6-day gap ($40-59\%$, `POSSIBLE MATCH`).
4. **Different item:** Decathlon Rain Umbrella vs. Dell Laptop in Library ($< 20\%$, `NO MATCH`, `is_match: False`).
5. **Missing fields:** Brass keys with omitted brand and color; handles gracefully without exceptions.
6. **Conflicting information:** Apple iPhone vs. Dell Charger in Lecture Hall 3; detects brand conflict penalty and flags `✗ Brand conflicts`.

Run the full suite with:
```bash
cd task-2-campus-intelligence
python -m unittest discover -s tests -v
```

---

## 5. Demo Dataset

A campus dataset is provided in [`campus_intelligence/matching/demo_data.py`](file:///d:/CampusOS/CampusOS/task-2-campus-intelligence/campus_intelligence/matching/demo_data.py):
```python
from campus_intelligence.matching.demo_data import get_demo_dataset

lost_items, found_items = get_demo_dataset()
```
Contains realistic campus items:
- Casio Scientific Calculators
- Apple MacBook Air laptops
- Hydro Flask insulated bottles
- Dorm keys
- Decathlon umbrellas
- iPhones & Dell chargers

---

## 6. Integration Instructions for Jitin (Task-1 Lead)

1. **CLI / Subprocess Integration:**  
   Task-1 can query matches over standard JSON stdin/stdout:
   ```bash
   python -m campus_intelligence.cli match --input '{"lost_item": {...}, "found_item": {...}}'
   ```
   Or generate human-readable explanations directly:
   ```bash
   python -m campus_intelligence.cli match --input '{"lost_item": {...}, "found_item": {...}}' --report
   ```

2. **Custom Weights:**  
   To prioritize specific attributes (e.g. strict brand matching for electronics):
   ```json
   {
     "lost_item": {...},
     "found_item": {...},
     "weights": {
       "category": 20.0,
       "item_type": 20.0,
       "brand": 30.0,
       "color": 15.0,
       "location": 5.0,
       "time": 5.0,
       "description": 5.0
     }
   }
   ```

3. **Ownership Verification Handshake:**  
   When `result.recommendation == "STRONG MATCH"` (score $\ge 80$), Task-1 should proceed to the **Ownership Verification** step per Section 4 of `docs/02_SRD.md`.

---

## 7. Limitations & Known Boundaries

1. **Deterministic Heuristics:** Matches are calculated via weighted attribute comparison and string tokenization (Jaccard similarity). It intentionally avoids heavy neural embeddings (e.g. BERT/CLIP) to ensure instant execution, zero cloud cost, and explainability.
2. **Date Boundaries:** Time proximity uses standard timestamps; missing timestamps on found reports receive 0 time points without penalizing other matching dimensions.
3. **Spelling Variations:** Handles case, punctuation, and known category synonyms; severe misspellings (e.g. 3+ character typos in brand names) may lower brand score.
