"""Campus issue classification taxonomy and keyword rules.

Authoritative mapping for categories, subcategories, and responsible departments.
Deterministic, explainable, and transparent.
"""

from typing import Dict, Any, List, Optional
from campus_intelligence.core.types import IssueCategory, CampusDepartment


TAXONOMY: List[Dict[str, Any]] = [
    {
        "category": IssueCategory.EQUIPMENT.value,
        "subcategory": "projector",
        "department": CampusDepartment.IT.value,
        "keywords": ["projector", "hdmi", "screen", "display", "av", "presentation", "audio", "mic", "microphone", "speaker"],
        "weight": 1.2,
    },
    {
        "category": IssueCategory.EQUIPMENT.value,
        "subcategory": "computer_lab",
        "department": CampusDepartment.IT.value,
        "keywords": ["computer", "pc", "desktop", "monitor", "keyboard", "mouse", "cpu", "lab system", "printer"],
        "weight": 1.1,
    },
    {
        "category": IssueCategory.WIFI.value,
        "subcategory": "network_connectivity",
        "department": CampusDepartment.IT.value,
        "keywords": ["wifi", "wi-fi", "internet", "ethernet", "lan", "network", "bandwidth", "router", "access point", "signal", "offline"],
        "weight": 1.3,
    },
    {
        "category": IssueCategory.ELECTRICAL.value,
        "subcategory": "lighting",
        "department": CampusDepartment.ELECTRICAL.value,
        "keywords": ["light", "tube light", "bulb", "lamp", "flickering", "dark", "lighting", "illumination"],
        "weight": 1.1,
    },
    {
        "category": IssueCategory.ELECTRICAL.value,
        "subcategory": "power_sockets",
        "department": CampusDepartment.ELECTRICAL.value,
        "keywords": ["socket", "plug", "switch", "power", "switchboard", "spark", "circuit", "short circuit", "voltage", "fuse"],
        "weight": 1.2,
    },
    {
        "category": IssueCategory.ELECTRICAL.value,
        "subcategory": "air_conditioning_fan",
        "department": CampusDepartment.ELECTRICAL.value,
        "keywords": ["fan", "ceiling fan", "ac", "air conditioner", "cooling", "hvac", "thermostat", "blower", "ventilation"],
        "weight": 1.1,
    },
    {
        "category": IssueCategory.WATER.value,
        "subcategory": "plumbing",
        "department": CampusDepartment.ESTATE.value,
        "keywords": ["water", "tap", "leak", "leakage", "pipe", "faucet", "cooler", "drinking water", "drainage", "sink", "flush", "overflow", "no water"],
        "weight": 1.2,
    },
    {
        "category": IssueCategory.CLEANLINESS.value,
        "subcategory": "housekeeping",
        "department": CampusDepartment.SANITATION.value,
        "keywords": ["dirty", "garbage", "trash", "waste", "dustbin", "litter", "spill", "unclean", "stink", "smell", "dust", "cleaning", "washroom", "toilet", "restroom"],
        "weight": 1.1,
    },
    {
        "category": IssueCategory.CLASSROOM.value,
        "subcategory": "furniture_infra",
        "department": CampusDepartment.ESTATE.value,
        "keywords": ["bench", "desk", "chair", "board", "whiteboard", "blackboard", "duster", "podium", "door", "window", "lock", "broken desk"],
        "weight": 1.0,
    },
    {
        "category": IssueCategory.HOSTEL.value,
        "subcategory": "hostel_facility",
        "department": CampusDepartment.HOSTEL.value,
        "keywords": ["hostel", "dorm", "mess", "warden", "room key", "mattress", "bed", "geyser", "curfew", "laundry"],
        "weight": 1.2,
    },
]


def extract_location_context(location: Optional[str]) -> Dict[str, Any]:
    """Extract contextual hints from location name (e.g. Lab, Hostel, Library)."""
    if not location:
        return {}
    loc = location.lower()
    hints = {}
    if "hostel" in loc or "block a" in loc or "block b" in loc or "dorm" in loc:
        hints["preferred_category"] = IssueCategory.HOSTEL.value
        hints["preferred_department"] = CampusDepartment.HOSTEL.value
    elif "lab" in loc or "computer" in loc:
        hints["preferred_category"] = IssueCategory.EQUIPMENT.value
        hints["preferred_department"] = CampusDepartment.IT.value
    elif "washroom" in loc or "toilet" in loc:
        hints["preferred_category"] = IssueCategory.CLEANLINESS.value
        hints["preferred_department"] = CampusDepartment.SANITATION.value
    elif "library" in loc:
        hints["is_quiet_zone"] = True
    return hints
