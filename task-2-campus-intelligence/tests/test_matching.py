"""Unit tests for MatchingService."""

import unittest
from campus_intelligence.core.models import LostItem, FoundItem
from campus_intelligence.matching.service import MatchingService


class TestMatchingService(unittest.TestCase):
    def setUp(self):
        self.service = MatchingService()

    def test_casio_calculator_strong_match(self):
        """Test the canonical PRD scenario: lost Casio calculator matched with found Casio calculator in Library."""
        lost = LostItem(
            id="lost-101",
            item_name="Casio Scientific Calculator",
            category="Electronics",
            brand="Casio",
            color="black",
            location="Central Library 2nd Floor",
            occurred_at="2026-10-07T10:00:00",
            description="Casio fx-991EX scientific calculator with solar panel",
        )
        found = FoundItem(
            id="found-201",
            item_name="Scientific Calculator",
            category="Electronics",
            brand="Casio",
            color="black",
            location="Library Reading Room",
            occurred_at="2026-10-07T11:30:00",
            description="Found a black Casio calculator left on the study desk",
        )

        result = self.service.calculate_match(lost, found)

        self.assertGreaterEqual(result.score, 80)
        self.assertIn(result.confidence, ["high", "very_high"])
        self.assertTrue(result.is_match)
        self.assertIn("category_match", result.factors)
        self.assertIn("brand_match", result.factors)
        self.assertIn("color_match", result.factors)
        self.assertIn("location_proximity", result.factors)
        self.assertIn("time_proximity", result.factors)

    def test_category_mismatch_low_score(self):
        """Items in completely different categories should produce low score."""
        lost = LostItem(
            id="lost-102",
            item_name="Blue Umbrella",
            category="Accessories",
            brand="Decathlon",
            color="blue",
            location="Cafeteria",
            occurred_at="2026-10-07T12:00:00",
        )
        found = FoundItem(
            id="found-202",
            item_name="Dell Laptop Charger",
            category="Electronics",
            brand="Dell",
            color="black",
            location="Auditorium",
            occurred_at="2026-10-07T12:00:00",
        )

        result = self.service.calculate_match(lost, found)
        self.assertLess(result.score, 40)
        self.assertFalse(result.is_match)
        self.assertNotIn("category_match", result.factors)

    def test_missing_optional_fields_does_not_crash(self):
        """Missing brand, color, or description should not raise exceptions."""
        lost = LostItem(
            id="lost-103",
            item_name="Keys",
            category="Personal",
        )
        found = FoundItem(
            id="found-203",
            item_name="Keychain with 2 keys",
            category="Personal",
        )

        result = self.service.calculate_match(lost, found)
        self.assertIsInstance(result.score, int)
        self.assertIn("category_match", result.factors)

    def test_case_and_whitespace_insensitivity(self):
        """Casing and irregular whitespace should be handled seamlessly."""
        lost = LostItem(
            id="lost-104",
            item_name="  APPLE   MacBook Pro ",
            category="electronics",
            brand=" Apple ",
            color="SILVER",
            location="room 101",
        )
        found = FoundItem(
            id="found-204",
            item_name="apple macbook",
            category="ELECTRONICS",
            brand="apple",
            color="silver",
            location="Room 101",
        )

        result = self.service.calculate_match(lost, found)
        self.assertGreaterEqual(result.score, 80)
        self.assertIn("brand_match", result.factors)
        self.assertIn("color_match", result.factors)

    def test_dict_input_support(self):
        """Service should accept plain dictionaries as well as dataclasses."""
        lost_dict = {
            "id": "lost-105",
            "item_name": "Hydro Flask Water Bottle",
            "category": "Personal",
            "brand": "Hydro Flask",
            "color": "Green",
        }
        found_dict = {
            "id": "found-205",
            "item_name": "Green Bottle",
            "category": "Personal",
            "brand": "Hydro Flask",
            "color": "Green",
        }

        result = self.service.calculate_match(lost_dict, found_dict)
        self.assertTrue(result.is_match)
        self.assertIn("brand_match", result.factors)

    def test_find_matches_for_lost_ranking(self):
        """Ranking multiple found items should return best matches first."""
        lost = LostItem(
            id="lost-106",
            item_name="Sony WH-1000XM4 Headphones",
            category="Electronics",
            brand="Sony",
            color="Black",
            location="Library 3rd Floor",
        )
        found_items = [
            FoundItem(id="f1", item_name="Red Scarf", category="Clothing", brand="Zara", color="Red"),
            FoundItem(id="f2", item_name="Sony Bluetooth Headphones", category="Electronics", brand="Sony", color="Black", location="Library"),
            FoundItem(id="f3", item_name="Bose Headphones", category="Electronics", brand="Bose", color="Black", location="Cafeteria"),
        ]

        matches = self.service.find_matches_for_lost(lost, found_items, threshold=40, limit=5)
        self.assertGreater(len(matches), 0)
        # Top result must be the Sony headphones
        self.assertEqual(matches[0].found_item_id, "f2")
        self.assertGreater(matches[0].score, matches[-1].score if len(matches) > 1 else 0)


if __name__ == "__main__":
    unittest.main()
