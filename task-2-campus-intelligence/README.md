# CampusOS — Campus Intelligence Engine (`task-2-campus-intelligence`)

**Owner:** Kartike (Task-2 Lead)\
**Phase:** Phase 1 — Intelligence Foundation\
**Status:** Authoritative Foundation Complete & Tested

---

## 1. Overview & Purpose

The Campus Intelligence Engine provides deterministic, explainable, and lightweight intelligence capabilities for CampusOS without introducing black-box ML models or heavy external dependencies.

It serves as the decision and analytics brain behind:
1. **Lost & Found Smart Matching:** Explainable similarity scoring across 6 weighted attributes.
2. **Issue Classification & Routing:** Classifying natural-language reports into standard categories and assigning responsible departments.
3. **Priority Scoring:** Transparent point-based assessment based on severity, location criticality, population impact, urgency, and recurrence.
4. **Problem Clustering:** Grouping localized and recurring campus failures into operational hotspots.
5. **Operational Analytics:** Calculating campus reliability index, SLA resolution times, and recovery rates.

---

## 2. Architecture & SOLID Principles

The module strictly follows the architecture defined in `docs/02_SRD.md` and `docs/03_ARCHITECTURE.md`:

```
task-2-campus-intelligence/
├── campus_intelligence/
│   ├── core/
│   │   ├── types.py          # Enums (PriorityLevel, MatchConfidence, IssueCategory, etc.)
│   │   ├── models.py         # DTOs (LostItem, FoundItem, MatchResult, IssueRecord, etc.)
│   │   └── interfaces.py      # Abstract Base Classes (IMatchingService, etc.)
│   ├── matching/             # Lost & Found Smart Matching Subsystem
│   │   ├── rules.py          # Deterministic feature weights & token overlap rules
│   │   └── service.py        # MatchingService
│   ├── classification/       # Issue Classification & Routing Subsystem
│   │   ├── rules.py          # Keyword taxonomy & location heuristics
│   │   └── service.py        # ClassificationService
│   ├── priority/             # Priority Evaluation Subsystem
│   │   ├── scoring.py        # Transparent point formulas & clamp logic
│   │   └── service.py        # PriorityService
│   ├── clustering/           # Problem Clustering Subsystem
│   │   ├── detector.py       # Spatio-temporal heuristics & topic generation
│   │   └── service.py        # ClusteringService
│   ├── analytics/            # Operational Analytics Subsystem
│   │   ├── metrics.py        # SLA, resolution rates & campus reliability formulas
│   │   └── service.py        # AnalyticsService
│   └── cli.py                # Unified JSON CLI for cross-runtime invocation
├── tests/                    # 27 comprehensive unit tests (100% pass)
└── pyproject.toml
```

### SOLID Compliance:
- **Single Responsibility:** Each subsystem has one distinct responsibility.
- **Open / Closed:** New classification keywords or scoring dimensions can be configured without rewriting service workflows.
- **Liskov Substitution:** All services implement strict abstract interfaces (`IMatchingService`, `IClassificationService`, etc.).
- **Interface Segregation:** Focused, fine-grained interfaces; callers depend only on what they use.
- **Dependency Inversion:** High-level services depend on abstractions in `core.interfaces`, completely decoupled from databases, UI, and networks.

---

## 3. Public Service Interfaces

### 3.1 `MatchingService` (`IMatchingService`)

```python
from campus_intelligence import MatchingService, LostItem, FoundItem

service = MatchingService()
result = service.calculate_match(lost_item, found_item, threshold=50)
```

**Output Structure (`MatchResult`):**
```json
{
  "score": 90,
  "confidence": "very_high",
  "factors": [
    "category_match",
    "brand_match",
    "color_match",
    "location_proximity",
    "description_similarity"
  ],
  "breakdown": {
    "category": 30.0,
    "brand": 20.0,
    "color": 15.0,
    "location": 15.0,
    "time": 0.0,
    "description_similarity": 10.0
  },
  "is_match": true,
  "lost_item_id": "lost-101",
  "found_item_id": "found-201"
}
```

---

### 3.2 `ClassificationService` (`IClassificationService`)

```python
from campus_intelligence import ClassificationService

service = ClassificationService()
result = service.classify_issue(
    title="Projector not working in B204",
    description="HDMI cord broken and cannot project slides",
    location="Room B204"
)
```

**Output Structure (`ClassificationResult`):**
```json
{
  "category": "equipment",
  "subcategory": "projector",
  "department": "IT",
  "confidence": 0.76,
  "matched_keywords": ["projector", "hdmi"]
}
```

---

### 3.3 `PriorityService` (`IPriorityService`)

```python
from campus_intelligence import PriorityService

service = PriorityService()
result = service.calculate_priority(
    category="equipment",
    severity="high",
    location="Room B204",
    affected_users=60,
    urgency="today",
    recurrence_count=2
)
```

**Output Structure (`PriorityResult`):**
```json
{
  "priority": "HIGH",
  "score": 65,
  "explanation": [
    "High severity (+30 pts)",
    "General campus location: 'Room B204' (+5 pts)",
    "High classroom/floor impact: 60 affected users (+15 pts)",
    "Same-day urgency declared (+10 pts)",
    "Recurring issue detected: reported 2 times (+5 pts)"
  ],
  "breakdown": {
    "severity": 30,
    "location": 5,
    "affected_users": 15,
    "urgency": 10,
    "recurrence": 5
  }
}
```

---

### 3.4 `ClusteringService` (`IClusteringService`)

```python
from campus_intelligence import ClusteringService, IssueRecord

service = ClusteringService()
clusters = service.cluster_issues(issues_list, time_window_hours=72)
```

**Output Structure (`List[IssueCluster]`):**
```json
[
  {
    "cluster_id": "cluster-001",
    "topic": "Recurring Projector Issues in Room B204 (3 reports)",
    "location": "Room B204",
    "primary_category": "equipment",
    "issue_count": 3,
    "issue_ids": ["iss-1", "iss-2", "iss-3"],
    "is_recurring": true,
    "severity_level": "HIGH"
  }
]
```

---

### 3.5 `AnalyticsService` (`IAnalyticsService`)

```python
from campus_intelligence import AnalyticsService

service = AnalyticsService()
analytics = service.calculate_campus_analytics(issues, lost_items, found_items)
```

**Output Structure (`CampusAnalytics`):**
```json
{
  "total_issues": 15,
  "active_issues": 3,
  "resolved_issues": 12,
  "resolution_rate": 80.0,
  "average_resolution_time_hours": 3.8,
  "lost_found_recovery_rate": 60.0,
  "category_distribution": { "equipment": 8, "wifi": 4, "electrical": 3 },
  "location_distribution": { "Room B204": 5, "Library": 6, "Hostel 3": 4 },
  "department_performance": {
    "IT": { "total": 12, "resolved": 10, "active": 2 }
  },
  "recurring_clusters_count": 1,
  "campus_reliability_score": 83.0
}
```

---

## 4. CLI Execution (Cross-Runtime Integration)

External clients (such as Flutter local backend scripts or CI/CD pipelines) can invoke any service via CLI:

```bash
# Issue classification
python -m campus_intelligence.cli classify --input '{"title": "Projector broken", "description": "HDMI port faulty", "location": "B204"}'

# Priority scoring
python -m campus_intelligence.cli priority --input '{"category": "electrical", "severity": "critical", "location": "Server Room", "affected_users": 150, "urgency": "immediate"}'

# Lost & Found matching
python -m campus_intelligence.cli match --input '{"lost_item": {...}, "found_item": {...}}'

# Issue clustering
python -m campus_intelligence.cli cluster --input '{"issues": [...]}'

# Campus Analytics
python -m campus_intelligence.cli analytics --input '{"issues": [...], "lost_items": [...], "found_items": [...]}'
```

---

## 5. Integration Guide for Task-1 (Jitin / Full-Stack)

1. **Clean Separation:** Task-1 never calls ML models or raw math in UI widgets. Call `MatchingService` / `ClassificationService` through an application use-case / repository boundary.
2. **Data Formats:** Services accept either Python dictionaries or strongly typed `dataclass` models (`LostItem`, `FoundItem`, `IssueRecord`). Every result provides a `.to_dict()` method for easy JSON serialization.
3. **Graceful Degradation:** If an intelligence service call times out or encounters invalid inputs, it falls back safely (e.g. classification returns `other` / `General Administration`; matching returns `is_match: False` with zero score) to satisfy Principle 18 (Graceful Failure) of `docs/03_ARCHITECTURE.md`.

---

## 6. Running Tests

Run all 27 unit tests using Python standard library `unittest` (no pip installs needed):

```bash
cd task-2-campus-intelligence
python -m unittest discover -s tests -v
```
