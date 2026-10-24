# Verification and evaluation plan

**Status:** executed in part and updated 24 October 2026; student acceptance review pending.  
**Owner:** Bekbauly; reviewer: Dinmukhammed. **Related issue:** [#14](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/14).

## Purpose and acceptance rules

Verify the requirements through traceable evidence. A completed test run can contain failed acceptance checks. Use PASS for the tested condition, FAIL for a reproduced violation, PARTIAL for a limited layer, and NOT RUN for missing evidence. A mocked provider, SQLite check or Web demo does not establish live fare coverage, PostgreSQL deployment, native behavior or delivered push.

The detailed [results and reproduction commands](VERIFICATION_RESULTS.md), [backend JSON](evidence/backend-results-2026-10-24.json) and [Flutter evidence summary](evidence/flutter-results-2026-10-24.json) identify revisions and conditions. Preserve the evidence from failed checks when a later repair is verified.

## Requirements and test matrix

| Test | Requirements and expected behavior | Recorded status on 24 October |
| --- | --- | --- |
| VT-01 | FR-01: seed twice; 12 unique directional routes, reverse direction distinct | PASS in disposable SQLite |
| VT-02 | FR-02/09: future date accepted, past/malformed rejected; invalid collection horizon rejected | PASS for Flutter input and backend horizon; backend alert past-date check fails under VT-08 |
| VT-03 | FR-03/11, NFR-04: missing token, empty response, timeout and HTTP failure create no market quote | FAIL: all four return an unlabeled generated price; #20 |
| VT-04 | FR-04: histories isolate route and departure date and sort observations | Backend FAIL: requested date ignored; Flutter mocked filtering PASS; #21 |
| VT-05 | FR-05, NFR-01: preserve unknowns; equivalent instants agree; future source time flagged | Backend FAIL on three subchecks; Flutter metadata checks PASS; #20 |
| VT-06 | FR-12: replay does not create an independent source observation | FAIL: two rows for one replayed quote; #21 |
| VT-07 | FR-06: prior median excludes current; insufficient data explicit | Backend PARTIAL: empty case passes, prior median fails; Flutter prior median PASS; #21 |
| VT-08 | FR-07: positive threshold and valid route/date; invalid input returns 4xx | Backend FAIL: missing route 500, past date 200; Flutter local rule validation PASS; #22 |
| VT-09 | FR-08: logged delivery attempt, replay suppression and separate failure outcome | State-update suppression PASS only; real delivery NOT RUN and absent in code |
| VT-10 | FR-09/10/11: route/date flow, loading, empty/error/stale/single states, persistent local rules/favorites | PASS within Flutter Web/tests; native accessibility and real users NOT RUN |
| VT-11 | NFR-03/06: unauthorized collection rejected before work; finite request budget | FAIL: unauthenticated call writes 12 rows; authorized budget and secret-log audit NOT RUN; #22 |
| VT-12 | NFR-02: exact money/currency persistence and invalid values rejected | Backend FAIL: normalizer accepts negative/NaN/infinity; decimal DB migration NOT RUN; client hundredths checks PASS; #20 |
| VT-13 | NFR-04/05: reproducible setup, rollback and deployed storage/API readiness | PARTIAL: health, syntax, Web build and recorded environments; clean install/PostgreSQL/rollback NOT RUN |
| VT-14 | NFR-07: provisional history p95 <=2 s for 1,000 observations | Local PASS: p95 42.81 ms, 30 serial ASGI samples after 3 warmups; production acceptance NOT RUN |

## Executed verification

Backend revision `4c16b32647e9dc780eec368a4ce20f015986c539` was downloaded from GitHub and checked in an isolated Python 3.12.14 environment on Windows. Sixteen diagnostics completed: **6 PASS and 10 FAIL**. These counts refer to individual subchecks, not fourteen fully accepted requirements. Nine Python files parsed successfully. HTTP providers were mocked, credentials were placeholders, and the temporary SQLite database enabled foreign keys. No external provider requests or attempted external connections occurred.

Flutter revision `d14b0d8ae006b84e34b33470ba1b168849222057` passed **17 tests**, static analysis and a release Web build using Flutter 3.47.5/Dart 3.13.4. Browser checks at 390 by 844 pixels verified route/date selection, history, failure states and restoration of date, favorites and local tracking after reload. A widget check also exercised text scale 1.6. This is limited evidence, not an accessibility compliance finding. The previous 23 October diagnostic review is historical evidence; the results above are the newer check.

## Reproduction and defect handling

Run the committed offline runner against the exact backend revision using the documented dependencies and commands in VERIFICATION_RESULTS.md. It refuses external socket connections and writes a new JSON report. Expected backend failures are preserved as failures; exit code zero means the diagnostic run completed, not that acceptance passed. Inspect the summary.

Fix priorities are #20 source integrity and exact-money validation, #22 collection access and alert validation, then #21 history/identity/baseline consistency. Bekbauly implements backend repairs; Dinmukhammed checks the client contract. Rerun affected tests after each repair and retain the original evidence. Both students review before changing a task to Done. Do not trigger live collection while these gates fail.

## Evaluation protocol

After data-trust and access repairs, approve a finite pilot budget and a source-specific route/date list. Record collection outcome, source/cache status, request count, collection time, supplied source time, raw-response hash and distinct observation identity. Repeat fixed departure dates on later days; rolling horizons alone do not establish one flight's price trajectory. Missing results do not prove that no flight exists.

For a future price experiment, predict the next daily observation for a fixed route, departure and comparable context. Compare last observed price and prior median with the candidate on the same chronological cases. Fit features and baselines using earlier observations only; exclude synthetic data and replayed cached quotes from independent examples. Report MAE in KZT, sample count, coverage, span, horizons and missingness. Training and measured accuracy remain deferred until real distinct history supports a meaningful split. No minimum number of records alone guarantees suitability.

For usability, recruit 3–5 real participants and use a consistent route/date → history → local rule script. Record completion, errors, elapsed time and understanding of demo/freshness labels; anonymize answers and summarize changes. No participants or supervisor feedback have been supplied, so this study is NOT RUN.

## Outstanding acceptance gates

Remaining checks cover clean setup, PostgreSQL migration/rollback, source limits and permissions, fixed-date live coverage, native Android/iOS behavior, screen-reader and keyboard use, logged push delivery and retry/deduplication failures, and user/supervisor review. Gate the live-data pilot on #20/#21/#22. Gate public deployment on access control and configuration hygiene. Gate notification claims on actual delivery evidence. The checkpoint can present the verified demo and honest limitations while these MVP items remain open.
