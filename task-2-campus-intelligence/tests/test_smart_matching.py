"""Comprehensive Test Suite for Smart Lost & Found Matching (Phase-2).

Covers all 6 required test scenarios:
1. Exact match
2. Strong partial match
3. Weak match
4. Different item
5. Missing fields
6. Conflicting information
Plus:
- Configurable weights validation
- Demo dataset verification
- Formatted explanation report output
"""

import unittest
from campus_intelligence.core.models import LostItem, FoundItem
from campus_intelligence.matching.service import MatchingService
from campus_intelligence.matching.rules import MatchWeights
from campus_intelligence.matching.demo_data import get_demo_dataset


class TestSmartMatchingEngine(unittest.TestCase):
    def setUp(self):
        self.service = MatchingService()

    def test_1_exact_match(self):
        """Scenario 1: Exact match - all attributes align seamlessly."""
        lost = LostItem(
            id="lost-calc",
            item_name="Casio Scientific Calculator",
            item_type="Scientific Calculator",
            category="Electronics",
            brand="Casio",
            color="Black",
            location="Central Library 2nd Floor",
            occurred_at="2026-10-07T10:00:00",
            description="Casio fx-991EX classwiz calculator with solar cell",
        )
        found = FoundItem(
            id="found-calc",
            item_name="Scientific Calculator",
            item_type="Scientific Calculator",
            category="Electronics",
            brand="Casio",
            color="Black",
            location="Central Library 2nd Floor",
            occurred_at="2026-10-07T10:45:00",
            description="Casio fx-991EX scientific calculator with solar panel found on desk",
        )

        result = self.service.calculate_match(lost, found)

        # Assertions
        self.assertGreaterEqual(result.score, 90)
        self.assertEqual(result.recommendation, "STRONG MATCH")
        self.assertIn(result.confidence.lower(), ["high", "very_high"])
        self.assertTrue(result.is_match)

        # Check factors
        self.assertIn("category_match", result.matching_factors)
        self.assertIn("item_type_match", result.matching_factors)
        self.assertIn("brand_match", result.matching_factors)
        self.assertIn("color_match", result.matching_factors)
        self.assertIn("location_proximity", result.matching_factors)
        self.assertIn("time_proximity", result.matching_factors)

        # Check human-readable explanation
        exp_text = "\n".join(result.human_readable_explanation)
        self.assertIn("✓ Category matches", exp_text)
        self.assertIn("✓ Brand matches", exp_text)
        self.assertIn("✓ Color matches", exp_text)
        self.assertIn("✓ Location is nearby", exp_text)

    def test_2_strong_partial_match(self):
        """Scenario 2: Strong partial match - core attributes match, minor temporal/text gap."""
        lost = LostItem(
            id="lost-mac",
            item_name="MacBook Air",
            item_type="Laptop",
            category="Electronics",
            brand="Apple",
            color="Silver",
            location="Room B204",
            occurred_at="2026-10-05T14:00:00",
            description="Silver Apple MacBook Air with stickers",
        )
        found = FoundItem(
            id="found-mac",
            item_name="Apple Laptop",
            item_type="Laptop",
            category="Electronics",
            brand="Apple",
            color="Silver",
            location="Room B204",
            occurred_at="2026-10-07T10:00:00",  # ~1.8 days later
            description="Found a silver MacBook left behind in room 204",
        )

        result = self.service.calculate_match(lost, found)

        self.assertGreaterEqual(result.score, 80)
        self.assertLessEqual(result.score, 95)
        self.assertEqual(result.recommendation, "STRONG MATCH")
        self.assertIn(result.confidence.lower(), ["high", "very_high"])
        self.assertIn("brand_match", result.matching_factors)
        self.assertIn("color_match", result.matching_factors)

    def test_3_weak_match(self):
        """Scenario 3: Weak match - category matches, but brand unknown and time gap is large."""
        lost = LostItem(
            id="lost-bottle",
            item_name="Hydro Flask Bottle",
            item_type="Water Bottle",
            category="Personal",
            brand="Hydro Flask",
            color="Navy Blue",
            location="Campus Cafeteria",
            occurred_at="2026-09-30T12:00:00",
            description="Insulated vacuum flask with logo",
        )
        found = FoundItem(
            id="found-bottle",
            item_name="Water Bottle",
            item_type="Water Bottle",
            category="Personal",
            brand=None,  # Finder did not check brand
            color="Blue",
            location="Cafeteria Outside Table",
            occurred_at="2026-10-06T13:00:00",  # 6 days later
            description="Blue bottle found on table",
        )

        result = self.service.calculate_match(lost, found)

        self.assertGreaterEqual(result.score, 40)
        self.assertLess(result.score, 70)
        self.assertIn(result.recommendation, ["POSSIBLE MATCH", "POTENTIAL MATCH"])

    def test_4_different_item(self):
        """Scenario 4: Different item - completely distinct category and item type."""
        lost = LostItem(
            id="lost-umb",
            item_name="Blue Umbrella",
            item_type="Umbrella",
            category="Accessories",
            brand="Decathlon",
            color="Blue",
            location="Central Library",
            occurred_at="2026-10-07T10:00:00",
        )
        found = FoundItem(
            id="found-lap",
            item_name="Dell Inspiron",
            item_type="Laptop",
            category="Electronics",
            brand="Dell",
            color="Black",
            location="Central Library",
            occurred_at="2026-10-07T10:00:00",
        )

        result = self.service.calculate_match(lost, found)

        self.assertLess(result.score, 20)
        self.assertEqual(result.recommendation, "NO MATCH")
        self.assertFalse(result.is_match)
        self.assertNotIn("category_match", result.matching_factors)

    def test_5_missing_fields(self):
        """Scenario 5: Missing fields - items omit brand, color, or timestamp."""
        lost = LostItem(
            id="lost-key",
            item_name="Hostel Room Keys",
            item_type="Keys",
            category="Personal",
            brand=None,
            color=None,
            location="Hostel Block C",
            occurred_at=None,
            description="Two brass keys on ring",
        )
        found = FoundItem(
            id="found-key",
            item_name="Keys",
            item_type="Keys",
            category="Personal",
            brand=None,
            color=None,
            location="Hostel Block C Corridor",
            occurred_at=None,
            description="Keys found on corridor floor",
        )

        result = self.service.calculate_match(lost, found)

        # Should handle cleanly without raising exceptions
        self.assertIsInstance(result.score, int)
        self.assertIn("item_type_match", result.matching_factors)
        self.assertIn("category_match", result.matching_factors)
        exp_text = "\n".join(result.human_readable_explanation)
        self.assertIn("— Brand not specified", exp_text)
        self.assertIn("— Color not specified", exp_text)

    def test_6_conflicting_information(self):
        """Scenario 6: Conflicting information - same category & location, but conflicting brands."""
        lost = LostItem(
            id="lost-phone",
            item_name="iPhone 14 Pro",
            item_type="Phone",
            category="Electronics",
            brand="Apple",
            color="Purple",
            location="Lecture Hall 3",
            occurred_at="2026-10-07T11:00:00",
        )
        found = FoundItem(
            id="found-charger",
            item_name="Dell Laptop Charger",
            item_type="Charger",
            category="Electronics",
            brand="Dell",
            color="Black",
            location="Lecture Hall 3",
            occurred_at="2026-10-07T11:00:00",
        )

        result = self.service.calculate_match(lost, found)

        # Assert brand conflict penalized
        self.assertLessEqual(result.score, 35)
        self.assertIn(result.recommendation, ["NO MATCH", "WEAK MATCH"])
        exp_text = "\n".join(result.human_readable_explanation)
        self.assertIn("✗ Brand conflicts", exp_text)

    def test_configurable_weights(self):
        """Test that custom MatchWeights alters factor point contribution."""
        custom_weights = MatchWeights(
            category=10.0,
            item_type=10.0,
            brand=35.0,
            color=35.0,
            location=5.0,
            time=3.0,
            description=2.0,
        )
        self.assertTrue(custom_weights.validate())

        service = MatchingService(default_weights=custom_weights)

        lost = LostItem(id="l", item_name="Casio Watch", category="Accessories", brand="Casio", color="Black")
        found = FoundItem(id="f", item_name="Casio Watch", category="Accessories", brand="Casio", color="Black")

        result = service.calculate_match(lost, found)
        # Brand (35) + Color (35) + Category (10) + Item Type (10) = 90
        self.assertEqual(result.factor_scores["brand"], 35.0)
        self.assertEqual(result.factor_scores["color"], 35.0)

    def test_demo_dataset_matching(self):
        """Test that demo dataset functions return expected matching behavior."""
        lost_items, found_items = get_demo_dataset()
        self.assertGreaterEqual(len(lost_items), 5)
        self.assertGreaterEqual(len(found_items), 5)

        # Match Casio calculator (lost-001) against all found items
        matches = self.service.find_matches_for_lost(lost_items[0], found_items, threshold=50)
        self.assertGreater(len(matches), 0)
        # Top match must be found-001
        self.assertEqual(matches[0].found_item_id, "found-001")
        self.assertEqual(matches[0].recommendation, "STRONG MATCH")

    def test_formatted_report_generation(self):
        """Test formatting human-readable text report output."""
        lost = LostItem(
            id="l-demo",
            item_name="Casio Calculator",
            category="Electronics",
            brand="Casio",
            color="Black",
            location="Library",
            occurred_at="2026-10-07T10:00:00",
        )
        found = FoundItem(
            id="f-demo",
            item_name="Calculator",
            category="Electronics",
            brand="Casio",
            color="Black",
            location="Library",
            occurred_at="2026-10-07T10:30:00",
        )

        res = self.service.calculate_match(lost, found)
        report = MatchingService.format_explanation_report(res)

        self.assertIn("STRONG MATCH", report)
        self.assertIn("CONFIDENCE", report)
        self.assertIn("✓ Category matches", report)
        self.assertIn("Recommendation:", report)


if __name__ == "__main__":
    unittest.main()
