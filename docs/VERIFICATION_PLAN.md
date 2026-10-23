# Verification and evaluation plan

**Status:** draft plan, 23 October 2026; measurements and acceptance review pending.  
**Related issue:** [#14](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/14)

## Purpose and evidence rules

Demonstrate that the requirements and project aim are met using reproducible checks. Separate code inspection, mocked/offline checks, live-source pilots, deployment verification and user evaluation. A successful HTTP response does not prove a real market fare or a delivered notification.

## Test matrix

| Test | Requirements | Setup and expected result |
| --- | --- | --- |
| VT-01 Route initialization | FR-01 | Start with an empty test DB, seed twice; active directions are unique and reverse directions remain distinct. |
| VT-02 Date input | FR-02/09 | Exercise future, past and malformed dates in prototype/API; invalid input has a clear explanation. |
| VT-03 Provider outcomes | FR-03/11, NFR-03/04 | Mock success, empty data, timeout and HTTP failure; only real labeled success creates a real quote; errors remain explicit. |
| VT-04 History isolation | FR-04 | Insert two departure dates for one route; each requested history contains only its date in collection order. |
| VT-05 Time correctness | FR-05, NFR-01 | Use UTC and +05:00 representations of the same instant, unknown time and future time; ages match and unknown/invalid states are preserved. |
| VT-06 Observation identity | FR-12 | Import the same source observation twice and then a distinct later observation; only the latter extends independent price history. |
| VT-07 Assessment baseline | FR-06 | Use hand-calculable prices and sparse/constant histories; values match the declared formula and insufficient data is explicit. |
| VT-08 Alert input | FR-07, NFR-02 | Check valid rule, missing route, invalid date, negative/NaN price and deactivation; invalid input yields client errors. |
| VT-09 Alert delivery | FR-08 | Use a fake delivery adapter; crossing the threshold creates one delivery attempt, replay does not, and failure does not become delivered success. |
| VT-10 UI scenarios | FR-02/04/05/09/10 | Complete route/date → history → tracking and inspect loading, no-data, offline/stale and error states. |
| VT-11 Access and budget | NFR-03/06 | Unauthorized collection makes zero provider requests; an authorized run remains within its configured request budget; logs contain no credentials. |
| VT-12 Monetary persistence | NFR-02 | Round-trip decimal amounts and currency; reject invalid values without partial writes. |
| VT-13 Deployment/reproducibility | NFR-04/05 | Follow setup on a clean environment, confirm DB readiness and read endpoints, record versions and errors. |
| VT-14 Performance | NFR-07 | Measure p95 history latency for 1,000 observations under a documented local configuration; review the proposed ≤2 s target before acceptance. |

## Existing evidence

An isolated review of backend commit 5c4d52efb5b6076d9cffc8fbff93e9691a3f360b used Python 3.12.14, disposable SQLite with foreign keys, and mocked HTTP responses. It exercised 12 diagnostic scenarios. Health/routes returned HTTP 200 and initialized 12 directions; no-data analytics returned INSUFFICIENT_DATA.

The same review reproduced unlabeled simulation, departure-as-source-time mapping, discarded time-zone offsets, repeated snapshot rows, mixed-date history and HTTP 500 for an unknown alert route. These are observed defects, not passed acceptance criteria. It did not verify PostgreSQL deployment or live fares. Details are in the main README's backend-review section.

## Live-source pilot

After source-time and real/simulated separation fixes, agree a small request budget and test selected route/date combinations. Record provider, request conditions, collection time, source time if supplied, observed availability, outcome, and raw-response provenance. Repeat on another day for fixed departure dates. Measure returned coverage and distinct observations; missing results are not proof that no flight exists.

## Statistical/ML evaluation

- Begin with a last-observed-price or prior-history-median baseline and document its grouping.
- Compare the linear baseline and any later ML candidate on the same chronological split.
- Features and baselines use only information available before each assessed observation.
- Keep repeated cached quotes and synthetic data out of independent train/test examples.
- Report MAE and the sample count, route/date coverage, collection span and missingness. Do not infer annual seasonality from a short collection period.
- If data are insufficient, report that limitation and evaluate descriptive functionality instead of fabricating accuracy.

## User evaluation and reporting

Before testing, choose 3–5 target-user representatives and a consistent script. Measure scenario completion, time, errors, and understanding of timestamps/assessment; record anonymized feedback. State participant count and conditions. Do not present the planned test as a completed study.

Each result should include test ID, source revision, environment, fixture/source, expected/actual outcome, timestamp, evidence and reviewer. A failed check becomes a tracked issue; only a verified repair changes its status.
