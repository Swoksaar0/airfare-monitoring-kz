# Initial requirements specification

**Status:** proposed requirements for peer/supervisor review, 23 October 2026.  
**Related issue:** [#4](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/4)

Priorities: **Must** = essential for the intended MVP, **Should** = valuable extension. These are acceptance targets, not claims of current completion. The 24 October checkpoint requires this specification and prototype materials; it does not require the whole MVP.

## Actors and main scenario

A traveler selects a directional route and departure date, views available observations and their freshness, inspects history/assessment, and creates a price-threshold rule. An operator controls collection and reviews failures. The published collector currently lacks operator access controls.

## Functional requirements

| ID | Priority | Requirement | Acceptance criteria |
| --- | --- | --- | --- |
| FR-01 | Must | List selected domestic routes | Return the configured active directions with origin/destination codes and names; inactive directions are excluded; reverse directions remain distinct. |
| FR-02 | Must | Select a departure date | The client accepts a valid future date for the selected direction; invalid/past input is explained; selected route/date persists across relevant screens. |
| FR-03 | Must | Collect source observations | A controlled run records its target, source, outcome and collection time; unavailable/error responses do not become generated market prices. |
| FR-04 | Must | Show route/date-specific history | Given observations for two departure dates, requesting either date returns only that date's observations in collection-time order; no-data is represented explicitly. |
| FR-05 | Must | Explain freshness and unknowns | Show collection time and source time if supplied; missing source time remains unknown; a departure timestamp is never used as price-observation time. |
| FR-06 | Must | Provide descriptive assessment | Compute a documented median/baseline on the declared group; prior-history comparisons exclude the current assessed observation; insufficient data is explicit. |
| FR-07 | Must | Manage a threshold rule | A valid route/date/positive-price rule can be created and deactivated; invalid references return a documented client error rather than HTTP 500. |
| FR-08 | Must | Deliver and deduplicate notifications | A qualifying new observation causes a logged delivery attempt; repeating the same observation does not cause another notification; failures remain distinguishable from delivery success. |
| FR-09 | Must | Present loading, missing and error states | The prototype/client demonstrates each state without stale or simulated data appearing as a successful new live result. |
| FR-10 | Should | Save favorite directions | Favorites survive an application restart and can be removed; this does not imply server-side alert creation. |
| FR-11 | Must | Separate demonstration data | Generated observations are explicitly labeled and isolated from real collection, history-based conclusions and reported ML evaluation. |
| FR-12 | Must | Preserve source identity/provenance | Reimporting the same source observation does not create a new independent price-change/ML example; a later distinct observation can extend history. |

## Non-functional requirements

| ID | Priority | Requirement and proposed acceptance |
| --- | --- | --- |
| NFR-01 | Must | Store instants consistently in UTC; equivalent timestamps with different offsets yield the same quote age; future/invalid source times are flagged. |
| NFR-02 | Must | Preserve exact monetary values with currency; reject negative/non-finite prices; verify round trips using boundary and decimal examples. |
| NFR-03 | Must | Control collection load and access: one operator-triggered run has a documented request budget; no unbounded polling; unauthorized triggering is rejected before any provider call. |
| NFR-04 | Must | Recover predictably from failure: a provider timeout/empty response is logged distinctly, failed transactions roll back, and previous valid observations remain readable. |
| NFR-05 | Must | Support reproducibility: documented dependencies/configuration and tests let another team member reproduce checks without real credentials or paid requests. |
| NFR-06 | Must | Protect credentials/device identifiers: real secrets stay out of Git; logs and public examples contain no device tokens or authentication material. |
| NFR-07 | Should | Initial performance target: history response p95 ≤2 s with 1,000 observations under a declared local test setup; this is a proposed target requiring review and measurement. |
| NFR-08 | Must | Keep the interface understandable: label currency, route/date and freshness; show a readable alternative when no assessment can be justified. |

## Present-code gap assessment

FR-01 has implementation evidence. FR-02/04/06/07/12 are partial or require changes. FR-03/05/11 fail the current collector's data-trust requirements. Actual FR-08 delivery is absent. A Flutter demo now presents route/history, local thresholds and session favorites; native behavior and durable-storage acceptance for FR-09/10 remain unverified.

The code uses floating-point prices, invents missing metadata, stores repeated quotes, mixes departure dates in the history endpoint, and lacks collection authentication. Listing these requirements does not mean those gaps have been fixed.

## Traceability

The use cases and components are described in [ARCHITECTURE.md](ARCHITECTURE.md). Test cases are mapped to these identifiers in [VERIFICATION_PLAN.md](VERIFICATION_PLAN.md). Record user-discussion findings and supervisor changes before treating this specification as agreed.
