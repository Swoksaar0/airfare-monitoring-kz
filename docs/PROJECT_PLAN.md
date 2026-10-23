# Project plan, responsibilities, risks and dependencies

**Status:** proposed plan for review, 23 October 2026.  
**Related issue:** [#8](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/8)

## Responsibilities

Dinmukhammed owns user-facing requirements, user research, prototype, mobile client and notifications. Bekbauly owns source access, backend, database and analytics. Both review interfaces, documentation, experiments and integration. Task ownership does not imply that the assignee has already reviewed or accepted a draft prepared for them.

## Immediate checkpoint work

| Sequence | Deliverable | Responsible | Dependency / review | Target |
| --- | --- | --- | --- | --- |
| 1 | Proposal, requirements and diagrams | Dinmukhammed / Bekbauly according to issues #1/#4/#5/#12 | Cross-review and consistency | 23 Oct |
| 2 | 3–5 user discussions | Dinmukhammed | Real respondents; use evidence template | 23–24 Oct |
| 3 | Literature review: ≥12 sources, ≥8 scientific | Both; #7 and #13 | Distinct sources and critical synthesis | 23–24 Oct |
| 4 | Existing-system and technology comparisons | Dinmukhammed #3; Bekbauly #11 | Supported criteria, requirements | 23–24 Oct |
| 5 | Key-scenario prototype | Dinmukhammed #6 | Draft requirements and data labels | 24 Oct |
| 6 | Verification plan and factual backend evidence | Bekbauly #14 | Baseline, metrics, reproducible conditions | 23–24 Oct |
| 7 | Supervisor review and response | Bekbauly #15; both apply comments | Materials available; actual review appointment | 24 Oct |
| 8 | Submission/access/revision check | Bekbauly #16; Dinmukhammed reviews | Required artifacts and peer review | 24 Oct |

Targets express the proposed work order, not completed milestones. If discussions or supervisor availability prevent completion, record the missing evidence honestly and notify the supervisor.

## Later engineering milestones

1. Correct source provenance, timestamps and simulation handling before a real-data pilot.
2. Establish repeat collection for fixed departure cohorts, observation identity and reliable storage.
3. Stabilize route/date API contracts while implementing the mobile client.
4. Implement logged notification delivery and suppression.
5. Compare analytics/ML baselines only after suitable real history exists.
6. Complete deployment, user evaluation and final reproducibility checks.

## Risk register

| Risk | Effect | Mitigation | Owner |
| --- | --- | --- | --- |
| Provider restrictions, quotas or limited coverage | Missing prices or interrupted collection | Small coverage pilot, bounded requests, explicit missing/error outcomes | Bekbauly |
| Simulation or wrong timestamps treated as real | Invalid analysis and freshness claims | Separate demo data; preserve unknowns; validate source time/UTC before collection | Bekbauly |
| Insufficient distinct history | Unreliable ML evaluation | Start correct accumulation early; fixed dates; simple baseline; state insufficiency | Bekbauly |
| Mixed departure dates or duplicate cached quotes | Misleading graphs and sample counts | Route/date grouping and source identity | Both |
| Mobile/backend mismatch | Integration delays | Agree DTOs and scenario fixtures; review contract changes | Both |
| Notifications recorded but not delivered | False user expectations | Delivery adapter/log and failure tests | Dinmukhammed |
| Late user/supervisor feedback | Missing checkpoint evidence | Arrange real discussions and review promptly; track outstanding actions | Both |
| Broken links/access or missing artifacts | Unverifiable submission | Peer checklist and exact submission revision/tag | Both |

## Task and review workflow

Use existing GitHub issues with one assignee, priority, deadline, expected result and acceptance criteria. Add artifact/PR links. Keep statuses factual: Planned → In progress → In review → Done. Each student uses their own account; the other reviews significant changes. A draft document alone does not justify Done.

GitHub Projects is the selected alternative tracker according to the team's reported permission to use analogues. Preserve that permission when available. If the board fails to load, issue descriptions and assigned issue lists remain a traceable planning record; do not claim that the board configuration is verified.

## Submission gate

Verify repository access for supervisor/committee; include README, proposal, research/comparisons, requirements, editable diagram sources and readable exports, prototype, verification plan, task board and actual feedback evidence. After peer review, tag the exact agreed revision pre-defense-1 and provide links, completed-work summary, limitations and outstanding tasks. Do not move a previously submitted tag.
