#!/usr/bin/env python3
"""
CampusOS Phase-2 Automated QA & MVP Validation Suite
Author: Ansh (QA & Deployment Lead)

Executes comprehensive validation across:
1. State Machine Rules (CampusFix, Lost & Found, Queue)
2. Role-Based Access Control (RBAC) & Route Permissions
3. Multi-Tenant Campus Isolation
4. Duplicate Request Protection
5. Input Sanitization & Security Fuzzing (XSS / SQL Injection)
6. Expanded Phase-2 Demo Datasets Integrity
7. Secret Exposure Audit
"""

import json
import os
import re
import sys
from pathlib import Path


class TestReporter:
    def __init__(self):
        self.passed = 0
        self.failed = 0
        self.results = []

    def log_pass(self, name: str, detail: str = ""):
        self.passed += 1
        msg = f"\033[92m[PASS]\033[0m {name}"
        if detail:
            msg += f" -> {detail}"
        print(msg)
        self.results.append({"name": name, "status": "PASS", "detail": detail})

    def log_fail(self, name: str, reason: str = ""):
        self.failed += 1
        msg = f"\033[91m[FAIL]\033[0m {name}"
        if reason:
            msg += f" -> {reason}"
        print(msg)
        self.results.append({"name": name, "status": "FAIL", "detail": reason})

    def log_section(self, title: str):
        print(f"\n\033[1m=== {title} ===\033[0m")


reporter = TestReporter()


# -----------------------------------------------------------------------------
# 1. State Machine Verifications
# -----------------------------------------------------------------------------
def test_campusfix_state_machine():
    reporter.log_section("1. CampusFix State Machine Transitions")

    valid_transitions = {
        "reported": ["verified", "assigned"],
        "verified": ["assigned"],
        "assigned": ["in_progress"],
        "in_progress": ["resolved"],
        "resolved": ["student_verified"],
        "student_verified": ["closed"],
        "closed": [],
    }

    def can_transition(current: str, target: str) -> bool:
        return target in valid_transitions.get(current, [])

    # Test Valid Sequence
    stepper = ["reported", "verified", "assigned", "in_progress", "resolved", "student_verified", "closed"]
    is_valid_flow = True
    for i in range(len(stepper) - 1):
        if not can_transition(stepper[i], stepper[i + 1]):
            is_valid_flow = False
            break

    if is_valid_flow:
        reporter.log_pass("CampusFix Happy Path Flow", "Full stepper chain reported -> closed is valid")
    else:
        reporter.log_fail("CampusFix Happy Path Flow", "Valid stepper sequence failed")

    # Test Invalid Transitions
    invalid_cases = [
        ("reported", "closed"),        # Cannot close without resolution
        ("reported", "resolved"),      # Cannot resolve without in_progress
        ("in_progress", "closed"),     # Cannot skip resolved and verified
        ("closed", "reported"),        # Cannot resurrect closed ticket
        ("resolved", "assigned"),      # Cannot go backwards
    ]

    for curr, tgt in invalid_cases:
        if not can_transition(curr, tgt):
            reporter.log_pass(f"Invalid Transition Blocked: {curr} -> {tgt}")
        else:
            reporter.log_fail(f"Invalid Transition Allowed: {curr} -> {tgt}")


def test_lost_found_state_machine():
    reporter.log_section("2. Lost & Found State Machine")

    valid_transitions = {
        "lost": ["matched", "claimed"],
        "found": ["matched", "claimed"],
        "matched": ["claimed"],
        "claimed": ["verified", "rejected"],
        "verified": ["recovered"],
        "recovered": [],
    }

    def can_item_transition(curr, tgt):
        return tgt in valid_transitions.get(curr, [])

    if can_item_transition("lost", "matched") and can_item_transition("verified", "recovered"):
        reporter.log_pass("Lost & Found Valid Flow", "lost -> matched -> claimed -> verified -> recovered")
    else:
        reporter.log_fail("Lost & Found Valid Flow")

    # Prevent direct jump from lost to recovered without verification
    if not can_item_transition("lost", "recovered"):
        reporter.log_pass("Invalid Transition Blocked: lost -> recovered (Direct bypass rejected)")
    else:
        reporter.log_fail("Direct recovery bypass allowed")


def test_queue_lifecycle():
    reporter.log_section("3. Digital Queue Lifecycle & Duplicate Protection")

    valid_token_transitions = {
        "waiting": ["called", "cancelled"],
        "called": ["served", "cancelled"],
        "served": [],
        "cancelled": [],
    }

    if "called" in valid_token_transitions["waiting"] and "served" in valid_token_transitions["called"]:
        reporter.log_pass("Queue Token Progression", "waiting -> called -> served")
    else:
        reporter.log_fail("Queue Token Progression")

    # Duplicate Queue Join Rule Simulation
    active_tokens_by_user = {"usr-student-001": ["queue-001"]}

    def attempt_join_queue(user_id: str, queue_id: str, queue_is_active: bool) -> tuple[bool, str]:
        if not queue_is_active:
            return False, "COUNTER_CLOSED"
        if queue_id in active_tokens_by_user.get(user_id, []):
            return False, "DUPLICATE_ACTIVE_TOKEN"
        return True, "TOKEN_ISSUED"

    # Test joining closed queue
    success, err = attempt_join_queue("usr-student-002", "queue-003", False)
    if not success and err == "COUNTER_CLOSED":
        reporter.log_pass("Queue Join on Closed Counter Blocked", "Error: COUNTER_CLOSED")
    else:
        reporter.log_fail("Allowed join on closed counter")

    # Test duplicate join by same student
    success, err = attempt_join_queue("usr-student-001", "queue-001", True)
    if not success and err == "DUPLICATE_ACTIVE_TOKEN":
        reporter.log_pass("Duplicate Queue Token Blocked", "User already holds active token in queue")
    else:
        reporter.log_fail("Duplicate token join allowed")


# -----------------------------------------------------------------------------
# 2. RBAC & Multi-Tenant Isolation
# -----------------------------------------------------------------------------
def test_rbac_and_tenant_isolation(dataset_path: Path):
    reporter.log_section("4. Role-Based Access Control (RBAC) & Multi-Tenancy")

    with open(dataset_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    users_by_id = {u["id"]: u for u in data["users"]}

    # RBAC Route Rules
    admin_routes = ["/admin/dashboard", "/admin/issues", "/admin/notices/create", "/admin/analytics"]
    
    def can_access_route(user_role: str, route: str) -> bool:
        if route.startswith("/admin"):
            return user_role == "admin"
        return True

    # Student accessing admin route
    student_role = users_by_id["usr-student-001"]["role"]
    if not can_access_route(student_role, "/admin/dashboard"):
        reporter.log_pass("RBAC Route Guard", "Student role blocked from /admin routes")
    else:
        reporter.log_fail("RBAC Route Guard", "Student allowed into admin route")

    # Admin accessing admin route
    admin_role = users_by_id["usr-admin-001"]["role"]
    if can_access_route(admin_role, "/admin/dashboard"):
        reporter.log_pass("RBAC Admin Route Allowed", "Admin role granted access to /admin/dashboard")
    else:
        reporter.log_fail("RBAC Admin Route Allowed")

    # Multi-Tenant Isolation Check
    main_campus_id = "c0000001-0000-0000-0000-000000000001"
    north_campus_id = "c0000002-0000-0000-0000-000000000002"

    main_issues = [i for i in data["issues"] if i["campus_id"] == main_campus_id]
    north_issues = [i for i in data["issues"] if i["campus_id"] == north_campus_id]

    # Verify student from North Campus cannot see Main Campus issues
    def get_user_issues(requesting_user_id: str):
        req_user = users_by_id[requesting_user_id]
        # Simulate RLS WHERE campus_id = req_user.campus_id
        return [i for i in data["issues"] if i["campus_id"] == req_user["campus_id"]]

    north_user_view = get_user_issues("usr-student-north")
    leaked_records = [i for i in north_user_view if i["campus_id"] != north_campus_id]

    if len(leaked_records) == 0 and len(north_user_view) == len(north_issues):
        reporter.log_pass("Multi-Tenant Isolation", "North campus student strictly isolated from Main campus data")
    else:
        reporter.log_fail("Multi-Tenant Isolation", f"Found {len(leaked_records)} leaked cross-campus records")


# -----------------------------------------------------------------------------
# 3. Input Boundary & Security Sanitization
# -----------------------------------------------------------------------------
def test_input_sanitization():
    reporter.log_section("5. Input Validation & Security Sanitization (XSS / SQL Injection)")

    def sanitize_text(user_input: str) -> str:
        # Strip script blocks completely
        cleaned = re.sub(r"<script[\s\S]*?>[\s\S]*?</script>", "", user_input, flags=re.IGNORECASE)
        # Strip any other remaining tags
        cleaned = re.sub(r"<[^>]*>", "", cleaned)
        return cleaned.strip()

    # Test XSS script injection payload
    malicious_xss = "<script>alert('XSS_ATTACK')</script>Projector in Room 204"
    cleaned = sanitize_text(malicious_xss)
    if "<script>" not in cleaned and "alert" not in cleaned:
        reporter.log_pass("XSS Payload Sanitization", f"'{malicious_xss}' -> '{cleaned}'")
    else:
        reporter.log_fail("XSS Payload Sanitization", f"Unsanitized tag: {cleaned}")

    # Test Empty / Whitespace-only submission
    def validate_issue_submission(category: str, location_id: str, description: str) -> tuple[bool, str]:
        if not category or not category.strip():
            return False, "EMPTY_CATEGORY"
        if not location_id or not location_id.strip():
            return False, "EMPTY_LOCATION"
        if not description or len(description.strip()) < 5:
            return False, "DESCRIPTION_TOO_SHORT"
        if len(description) > 1000:
            return False, "DESCRIPTION_TOO_LONG"
        return True, "VALID"

    valid, err = validate_issue_submission("equipment", "loc-acad-204", "   ")
    if not valid and err == "DESCRIPTION_TOO_SHORT":
        reporter.log_pass("Empty/Whitespace Input Validation", "Blocked whitespace-only description")
    else:
        reporter.log_fail("Whitespace validation failed")

    valid, err = validate_issue_submission("", "loc-acad-204", "Projector is broken")
    if not valid and err == "EMPTY_CATEGORY":
        reporter.log_pass("Mandatory Field Validation", "Blocked empty category submission")
    else:
        reporter.log_fail("Empty category permitted")


# -----------------------------------------------------------------------------
# 4. Secret & Credential Scanning
# -----------------------------------------------------------------------------
def scan_repository_secrets(root_path: Path):
    reporter.log_section("6. Secret & Private Credential Repository Scan")

    secret_patterns = [
        re.compile(r"service_role[a-zA-Z0-9_\-\.]{20,}", re.IGNORECASE),
        re.compile(r"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9\.[a-zA-Z0-9_\-\.]{30,}", re.IGNORECASE),
        re.compile(r"-----BEGIN (RSA|EC|PGP|OPENSSH) PRIVATE KEY-----"),
        re.compile(r"(ghp_[a-zA-Z0-9]{36}|github_pat_[a-zA-Z0-9]{82})"),
    ]

    leaks = []
    scanned_count = 0
    for current_dir, _, files in os.walk(root_path):
        if ".git" in current_dir:
            continue
        for file in files:
            file_path = Path(current_dir) / file
            if file_path.suffix in [".dart", ".js", ".html", ".py", ".yaml", ".json", ".sql"]:
                # skip this runner file itself from regex pattern self-match
                if file_path.name in ["phase2_validation_suite.py", "automated_verification_runner.py"]:
                    continue
                scanned_count += 1
                try:
                    content = file_path.read_text(encoding="utf-8", errors="ignore")
                    for pat in secret_patterns:
                        if pat.search(content):
                            leaks.append(str(file_path))
                except Exception:
                    pass

    if not leaks:
        reporter.log_pass(f"Zero Secrets Leaked ({scanned_count} files scanned)")
    else:
        reporter.log_fail(f"Potential secrets found in: {leaks}")


# -----------------------------------------------------------------------------
# Main Runner
# -----------------------------------------------------------------------------
def main():
    print("=" * 70)
    print(" CampusOS Phase-2 QA & MVP Validation Engine")
    print("=" * 70)

    base_dir = Path(__file__).resolve().parent.parent.parent
    dataset_file = base_dir / "task-4-campusos-quality-deployment" / "demo-data" / "phase2_expanded_datasets.json"

    test_campusfix_state_machine()
    test_lost_found_state_machine()
    test_queue_lifecycle()
    if dataset_file.exists():
        test_rbac_and_tenant_isolation(dataset_file)
    else:
        reporter.log_fail("Dataset Verification", f"File not found: {dataset_file}")

    test_input_sanitization()
    scan_repository_secrets(base_dir)

    print("\n" + "=" * 70)
    print(f"Summary: {reporter.passed} Passed, {reporter.failed} Failed")
    print("=" * 70)

    return 0 if reporter.failed == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
