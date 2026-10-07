# CampusOS --- Branch Protection & Pull Request Policy

**Document Version:** 1.0  
**Phase:** Task 4 / Phase 1 — Development Infrastructure  
**Author:** Ansh (QA & Deployment Lead)  
**Authoritative Reference:** [05_ANTIGRAVITY_GITHUB_EXECUTION.md Sections 6, 13, 14](file:///c:/Users/anshc/Desktop/Main/CampusOS/CampusOS/docs/05_ANTIGRAVITY_GITHUB_EXECUTION.md#L160-L188)

---

## 1. Branch Naming Rules

Direct commits to the `main` branch are **STRICTLY PROHIBITED**.

All work must occur on designated task and phase branches following this exact schema:

```text
task-1/phase-1-foundation
task-1/phase-2-student-app
task-1/phase-3-backend
task-1/phase-4-integration

task-2/phase-1-intelligence-foundation
task-2/phase-2-smart-matching
task-2/phase-3-issue-intelligence
task-2/phase-4-campus-intelligence

task-3/phase-1-product-research
task-3/phase-2-user-flows
task-3/phase-3-design-system
task-3/phase-4-final-experience

task-4/phase-1-development-infrastructure
task-4/phase-2-quality-assurance
task-4/phase-3-security-deployment
task-4/phase-4-demo-documentation
```

---

## 2. Directory Ownership Boundaries

Each task lead may only modify files within their assigned directory:

- **Jitin**: `/task-1-campusos-fullstack/**`
- **Kartike**: `/task-2-campus-intelligence/**`
- **Arko**: `/task-3-campusos-product-experience/**`
- **Ansh**: `/task-4-campusos-quality-deployment/**`
- **Shared Directory Changes** (`shared/**`): Require explicit peer review and coordination between Task 1 and Task 4.

---

## 3. GitHub Branch Protection Policy for `main`

The GitHub repository administrator must enforce the following branch protection settings on `main`:

1. **Require a Pull Request before merging**:
   - Direct `git push origin main` blocked for all users.
2. **Require at least 1 approving review**:
   - Reviewer must be a teammate other than the PR author.
3. **Strictly Enforce "No Self-Merges" Rule**:
   - The task author is prohibited from approving or merging their own PR.
4. **Require Status Checks to Pass**:
   - Automated quality harness (`automated_verification_runner.py`) must pass.
   - Linting and analysis (`flutter analyze` / `dart format`) must be clean.
5. **Require Branches to be Up-to-Date before merging**:
   - PR branch must be rebased or fast-forwarded against the latest `main`.

---

## 4. Pull Request Workflow & Checklist

Every PR must use the template defined in [.github/pull_request_template.md](file:///c:/Users/anshc/Desktop/Main/CampusOS/CampusOS/.github/pull_request_template.md).

Before requesting a review, the author must confirm:
- [ ] Scope strictly matches the assigned phase.
- [ ] No changes outside assigned folder.
- [ ] `dart format` passed.
- [ ] `flutter analyze` passed.
- [ ] Verification harness passed.
- [ ] Zero secrets committed.
