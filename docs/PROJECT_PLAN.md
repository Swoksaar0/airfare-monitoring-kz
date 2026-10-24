# Project management and risks

**Baseline:** 24 October 2026; technical evidence recorded, student/supervisor agreement pending.  
**Related issue:** [#8](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/8). [Project board](https://github.com/users/Swoksaar0/projects/2/views/1).

## Responsibilities and coordination

Dinmukhammed (@Swoksaar0) owns requirements, user discussions, UX, Flutter, local tracking and future notification presentation. Bekbauly (@Bekbauly) owns provider access, backend, data storage and analytics. Backend commits already contain Bekbauly's implementation; the review identifies repairs to that work, not an absence of contribution. Both review the API contract, research, integration and submission materials. Ownership and an assistant-prepared draft are not proof that an individual completed reading or review.

Use a short daily issue update during active work: evidence produced, next action, blocker and requested decision. Review risks after every source/API change and before collection or submission. Do not send participant or supervisor messages automatically; the students arrange those discussions themselves.

## Checkpoint status and remaining work

| Work package | Evidence or current state | Owner and next gate |
| --- | --- | --- |
| Proposal, requirements, comparisons and diagrams; #1/#3/#4/#5/#11/#12 | Drafts available in documentation PR #18; acceptance review pending | Both: cross-check claims and agree scope |
| Literature; #7/#13 | 14 sources, 10 scholarly; synthesis available, reading and peer review unconfirmed | Both: review the allocated sources |
| Flutter prototype; #6 | Revision d14b0d8a; 17 passing tests, Web build and browser evidence | Dinmukhammed; Bekbauly reviews scenarios |
| Verification; #14 | Plan plus executed offline results, 6 passed and 10 failed backend diagnostics | Bekbauly; Dinmukhammed reviews evidence |
| Management; #8 | Owners, staged milestones, risks and linked defect issues prepared | Dinmukhammed; Bekbauly reviews; board fields/access unverified |
| User discussions; #2 | No real responses supplied | Dinmukhammed: conduct and record 3–5 discussions |
| Supervisor review; #15 | No substantive comments or approval supplied | Bekbauly: arrange consultation and record real decisions |
| Final submission; #16 | No agreed submission tag | Both: review package, access and remaining evidence |

Original issue targets were 23–24 October. Materials still awaiting human evidence or review are not retroactively complete. Keep original deadlines in issue history and record revised estimates separately. The checkpoint requires a justified plan and prototype; the entire production service is not claimed complete.

## Next milestones and dependencies

| Stage | Proposed target or trigger | Owner | Exit condition |
| --- | --- | --- | --- |
| M0 Checkpoint review | 24 October; human availability determines completion | Both | Reviewed documents/demo, real missing evidence identified, accessible links |
| M1 Data trust and collection control | Proposed 25 October; agree with team | Bekbauly | #20 and #22 repaired, affected checks pass and peer review recorded |
| M2 Comparable history and client contract | Proposed 26 October, after M1 | Bekbauly with Dinmukhammed | #21 passes, route/date fixtures agree, failures remain explicit |
| M3 Controlled source pilot | After M1/M2, source permission and quota approval | Bekbauly | Request budget recorded; fixed dates observed on multiple days with provenance |
| M4 Integrated mobile and delivery | After stable API and native setup | Dinmukhammed with Bekbauly | Real API read path and native persistence checked; delivery attempts/outcomes verified |
| M5 Analysis and final evaluation | When sufficient distinct real history exists | Both | Chronological baseline comparison, usability results and limitations reported |

These dates are estimates prepared for agreement, not promises attributed to either student. If a prerequisite fails, update the dependent estimate and preserve the blocker. Do not rush an unbounded source poll to recover schedule.

## Risk register and response actions

Score likelihood L and impact I from 1 to 3; risk score is L × I. Scores 6–9 are high, 3–4 medium, 1–2 low. These are qualitative planning judgments. For an observed defect, L=3 means it is already happening. Residual risk stays open until the stated evidence exists.

| Risk and score | Trigger or current evidence | Response and closure evidence | Owner |
| --- | --- | --- | --- |
| R1 Invalid observations; L3 I3 = 9 high | Generated prices, false source times and accepted invalid amounts reproduced | #20: explicit outcomes, UTC/unknown validation, demo isolation, exact money; affected tests pass | Bekbauly |
| R2 Uncontrolled collection; L3 I3 = 9 high | Unauthenticated collect succeeds; #22 | Keep collection private; authorize before work and enforce finite budget; denied requests make zero provider calls | Bekbauly |
| R3 Misleading history; L3 I3 = 9 high | Date mixing, replayed rows and current-inclusive median; #21 | Route/date/context grouping, identity and prior-only baseline; fixture regression passes | Bekbauly |
| R4 Missing source access/coverage; L2 I3 = 6 high | Quota/restriction, missing route/date result or stale cache during future pilot | Stop at configured budget; log errors, retain unknowns; pilot proves measured scope, no completeness claim | Bekbauly |
| R5 Insufficient real history; L3 I2 = 6 high | No trusted multi-day dataset verified | Accumulate fixed-date cohorts after repairs; defer ML when evidence is insufficient; report descriptive results | Bekbauly |
| R6 Mobile/server mismatch; L2 I2 = 4 medium | Client tests pass while backend contract fails | Shared fixtures and integration check after #21; native setup and persistence checked separately | Dinmukhammed |
| R7 False notification expectation; L3 I2 = 6 high | Local rules and last-notified fields exist; push delivery absent | Keep local-only label; add delivery adapter/log and failure/replay checks before notification claims | Dinmukhammed with Bekbauly |
| R8 Missing human evidence; L3 I3 = 9 high | Interviews, peer review and supervisor feedback outstanding | Students arrange real sessions; record anonymized findings and actual comments; preserve unresolved decisions | Both |
| R9 Unverifiable release/access; L2 I2 = 4 medium | Board access, submission tag and clean setup unverified | Check links/permissions and clean setup; agree exact reviewed revision, then tag once | Both |

## Task workflow and change control

Use existing issue ownership and acceptance criteria. Statuses are Planned → In progress → In review → Done; blocked items include a named dependency. The document package and prototype are ready for student review, not automatically Done. Three reproduced defect tasks, #20–#22, are open and assigned to Bekbauly with priorities and proposed dates in their descriptions.

For any scope, source or schema change, record the reason, affected requirement/test, owner, review and effect on the next milestone. Keep backend fixes on backend, mobile changes on mobile-app and report changes on pre-defense-documents. Review each diff before integration; branches still share a common Git baseline.

GitHub Projects is the team's selected alternative tracker. Issue descriptions hold traceable owner/priority/date information, but that does not set structured Project fields. Board membership, columns, edit permissions and the supervisor's access have not been verified here. Both students must check the board before claiming issue #8 complete. The reported permission to use an analogue should be retained when available.

## Submission and completion gate

Before submission, both students check proposal, source analysis, comparisons, requirements, editable diagrams/exports, Flutter walkthrough, verification outcomes, risks, real human feedback and links. Link unresolved defects rather than concealing them. Agree what is submitted and record the reviewers; only then create the exact pre-defense-1 revision/tag. Do not move a submitted tag. No supervisor approval, completed user study, production deployment or final acceptance is asserted by this package.
