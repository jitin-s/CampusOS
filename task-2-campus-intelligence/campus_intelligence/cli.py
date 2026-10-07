"""CampusOS Intelligence Engine - JSON CLI Interface.

Provides a unified command-line interface for invocation by external runtimes (e.g. Flutter subprocesses, CI, shell scripts).
Accepts JSON inputs and returns JSON outputs to stdout.
"""

import sys
import json
import argparse
from typing import Dict, Any

# Ensure UTF-8 stdout encoding on Windows consoles
if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

from campus_intelligence.matching.service import MatchingService
from campus_intelligence.classification.service import ClassificationService
from campus_intelligence.priority.service import PriorityService
from campus_intelligence.clustering.service import ClusteringService
from campus_intelligence.analytics.service import AnalyticsService


from campus_intelligence.matching.rules import MatchWeights


def handle_match(args: argparse.Namespace) -> None:
    service = MatchingService()
    if args.input:
        data = json.loads(args.input)
    else:
        data = json.load(sys.stdin)

    lost = data.get("lost_item", {})
    found = data.get("found_item", {})
    threshold = int(data.get("threshold", 50))
    weights_dict = data.get("weights")
    weights = MatchWeights(**weights_dict) if isinstance(weights_dict, dict) else None

    res = service.calculate_match(lost, found, threshold=threshold, weights=weights)
    if getattr(args, "report", False):
        print(MatchingService.format_explanation_report(res))
    else:
        print(json.dumps(res.to_dict(), indent=2))


def handle_classify(args: argparse.Namespace) -> None:
    service = ClassificationService()
    if args.input:
        data = json.loads(args.input)
    else:
        data = json.load(sys.stdin)

    title = data.get("title", "")
    description = data.get("description", "")
    location = data.get("location", "")

    res = service.classify_issue(title, description, location)
    print(json.dumps(res.to_dict(), indent=2))


def handle_priority(args: argparse.Namespace) -> None:
    service = PriorityService()
    if args.input:
        data = json.loads(args.input)
    else:
        data = json.load(sys.stdin)

    category = data.get("category", "")
    severity = data.get("severity", "medium")
    location = data.get("location", "")
    affected = int(data.get("affected_users", 1))
    urgency = data.get("urgency", "medium")
    recurrence = int(data.get("recurrence_count", 1))

    res = service.calculate_priority(category, severity, location, affected, urgency, recurrence)
    print(json.dumps(res.to_dict(), indent=2))


def handle_cluster(args: argparse.Namespace) -> None:
    service = ClusteringService()
    if args.input:
        data = json.loads(args.input)
    else:
        data = json.load(sys.stdin)

    issues = data.get("issues", [])
    clusters = service.cluster_issues(issues)
    print(json.dumps([c.to_dict() for c in clusters], indent=2))


def handle_analytics(args: argparse.Namespace) -> None:
    service = AnalyticsService()
    if args.input:
        data = json.loads(args.input)
    else:
        data = json.load(sys.stdin)

    issues = data.get("issues", [])
    lost = data.get("lost_items", [])
    found = data.get("found_items", [])

    analytics = service.calculate_campus_analytics(issues, lost, found)
    print(json.dumps(analytics.to_dict(), indent=2))


def main() -> None:
    parser = argparse.ArgumentParser(description="CampusOS Intelligence Engine CLI")
    subparsers = parser.add_subparsers(dest="command", required=True)

    p_match = subparsers.add_parser("match", help="Match lost and found items")
    p_match.add_argument("--input", "-i", type=str, help="JSON input string (or pipe via stdin)")
    p_match.add_argument("--report", "-r", action="store_true", help="Print human-readable text report")
    p_match.set_defaults(func=handle_match)

    p_classify = subparsers.add_parser("classify", help="Classify an issue")
    p_classify.add_argument("--input", "-i", type=str, help="JSON input string (or pipe via stdin)")
    p_classify.set_defaults(func=handle_classify)

    p_priority = subparsers.add_parser("priority", help="Calculate priority score")
    p_priority.add_argument("--input", "-i", type=str, help="JSON input string (or pipe via stdin)")
    p_priority.set_defaults(func=handle_priority)

    p_cluster = subparsers.add_parser("cluster", help="Cluster similar issues")
    p_cluster.add_argument("--input", "-i", type=str, help="JSON input string (or pipe via stdin)")
    p_cluster.set_defaults(func=handle_cluster)

    p_analytics = subparsers.add_parser("analytics", help="Calculate campus analytics")
    p_analytics.add_argument("--input", "-i", type=str, help="JSON input string (or pipe via stdin)")
    p_analytics.set_defaults(func=handle_analytics)

    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
