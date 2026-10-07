"""Realistic Campus Lost & Found Demo Dataset.

Provides curated pairs of lost and found items demonstrating:
1. Exact match (e.g. Casio fx-991EX Calculator in Library)
2. Strong partial match (e.g. Apple MacBook Air in Room B204)
3. Weak match (e.g. Blue Water Bottle in Cafeteria)
4. Different item (e.g. Umbrella vs Dell Laptop)
5. Missing fields (e.g. Keys with unknown brand/color)
6. Conflicting information (e.g. Apple iPhone vs Dell Laptop)
"""

from typing import List, Tuple
from campus_intelligence.core.models import LostItem, FoundItem


def get_demo_lost_items() -> List[LostItem]:
    """Return a list of representative lost items for testing and demonstration."""
    return [
        LostItem(
            id="lost-001",
            item_name="Casio Scientific Calculator",
            category="Electronics",
            item_type="Scientific Calculator",
            brand="Casio",
            color="Black",
            location="Central Library 2nd Floor",
            occurred_at="2026-10-07T10:00:00",
            description="Casio fx-991EX classwiz calculator with solar cell, slight scratch on lid",
        ),
        LostItem(
            id="lost-002",
            item_name="MacBook Air M2",
            category="Electronics",
            item_type="Laptop",
            brand="Apple",
            color="Silver",
            location="Room B204",
            occurred_at="2026-10-06T14:30:00",
            description="Silver MacBook Air 13-inch with a GitHub sticker on the cover",
        ),
        LostItem(
            id="lost-003",
            item_name="Hydro Flask Bottle",
            category="Personal",
            item_type="Water Bottle",
            brand="Hydro Flask",
            color="Navy Blue",
            location="Campus Cafeteria",
            occurred_at="2026-10-05T12:15:00",
            description="Navy blue insulated bottle with stainless steel cap",
        ),
        LostItem(
            id="lost-004",
            item_name="Dorm Room Keys",
            category="Personal",
            item_type="Keys",
            brand=None,
            color=None,
            location="Hostel Block C Corridor",
            occurred_at="2026-10-07T08:00:00",
            description="Ring with 2 silver brass keys and a blue plastic tag",
        ),
        LostItem(
            id="lost-005",
            item_name="Decathlon Rain Umbrella",
            category="Accessories",
            item_type="Umbrella",
            brand="Decathlon",
            color="Blue",
            location="Main Auditorium Entrance",
            occurred_at="2026-10-04T16:00:00",
            description="Compact foldable blue rain umbrella with black handle",
        ),
        LostItem(
            id="lost-006",
            item_name="iPhone 14 Pro",
            category="Electronics",
            item_type="Phone",
            brand="Apple",
            color="Deep Purple",
            location="Lecture Hall 3",
            occurred_at="2026-10-07T11:00:00",
            description="Apple iPhone with black silicone case and privacy screen protector",
        ),
    ]


def get_demo_found_items() -> List[FoundItem]:
    """Return a list of representative found items for testing and demonstration."""
    return [
        FoundItem(
            id="found-001",
            item_name="Scientific Calculator",
            category="Electronics",
            item_type="Scientific Calculator",
            brand="Casio",
            color="Black",
            location="Library Reading Room",
            occurred_at="2026-10-07T11:30:00",
            description="Found a black Casio fx-991EX calculator on study desk 14",
        ),
        FoundItem(
            id="found-002",
            item_name="Apple Laptop",
            category="Electronics",
            item_type="Laptop",
            brand="Apple",
            color="Silver",
            location="Room B204",
            occurred_at="2026-10-06T17:00:00",
            description="Silver laptop with stickers left on the podium",
        ),
        FoundItem(
            id="found-003",
            item_name="Water Bottle",
            category="Personal",
            item_type="Water Bottle",
            brand=None,  # Finder did not check brand
            color="Blue",
            location="Cafeteria Outside Table",
            occurred_at="2026-10-06T13:00:00",
            description="Blue metal bottle found after lunch hours",
        ),
        FoundItem(
            id="found-004",
            item_name="Set of Keys",
            category="Personal",
            item_type="Keys",
            brand=None,
            color=None,
            location="Hostel Block C",
            occurred_at="2026-10-07T08:30:00",
            description="Two keys on a ring found on staircase",
        ),
        FoundItem(
            id="found-005",
            item_name="Dell Inspiron Laptop",
            category="Electronics",
            item_type="Laptop",
            brand="Dell",
            color="Black",
            location="Main Auditorium",
            occurred_at="2026-10-07T09:00:00",
            description="Black Dell laptop found under seat G12",
        ),
        FoundItem(
            id="found-006",
            item_name="Dell Laptop Charger",
            category="Electronics",
            item_type="Charger",
            brand="Dell",
            color="Black",
            location="Lecture Hall 3",
            occurred_at="2026-10-07T12:00:00",
            description="65W Dell USB-C laptop power brick",
        ),
    ]


def get_demo_dataset() -> Tuple[List[LostItem], List[FoundItem]]:
    """Return full demo pair datasets."""
    return get_demo_lost_items(), get_demo_found_items()
