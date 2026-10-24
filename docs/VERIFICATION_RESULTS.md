# Verification results recorded on 24 October 2026

The Flutter Web prototype passes its recorded client checks. The backend is not ready for trustworthy live-data collection: the offline diagnostic run completed with 6 passed and 10 failed conditions. These are test outcomes, not six accepted system requirements. No external provider requests were made. A future repaired run must retain this original evidence.

## Revisions and conditions

- Backend/main: `4c16b32647e9dc780eec368a4ce20f015986c539`; downloaded source hashes appear in [backend JSON](evidence/backend-results-2026-10-24.json).
- Flutter: `d14b0d8ae006b84e34b33470ba1b168849222057`; [test sources](https://github.com/Swoksaar0/airfare-monitoring-kz/tree/d14b0d8ae006b84e34b33470ba1b168849222057/mobile/test) and [summary](evidence/flutter-results-2026-10-24.json).
- Backend execution: 2026-10-24T10:18:47.300506+00:00; Python 3.12.14, Windows 11, disposable SQLite with foreign keys; ASGI TestClient in process. Provider HTTP was mocked; real tokens/device IDs were not used. External socket connections were guarded, with zero blocked external attempts.
- The ASGI performance measurement uses one serial client, 1,000 synthetic rows, 3 warmups and 30 measured requests: nearest-rank p95 42.81 ms; median 14.15 ms. This excludes production networking, TLS, provider calls, load/concurrency and PostgreSQL. The provisional 2 s target is not production acceptance.
- Test-client deprecation warning: the installed Starlette stack warns about its httpx TestClient path. Tests completed; dependency compatibility should be reviewed before upgrading.

## Backend outcomes

| ID | Diagnostic | Outcome | Actual result |
| --- | --- | --- | --- |
| VT-01 | Unique idempotent route seed | PASS | 12 unique routes; second seed adds zero |
| VT-13a | Health endpoint | PASS | HTTP 200 |
| VT-07a | Empty analytics | PASS | INSUFFICIENT_DATA |
| VT-02a | Collection horizon validation | PASS | All three invalid horizons return 422 |
| VT-03 | Missing and failed provider responses | FAIL | Missing/empty/timeout/error each return generated price |
| VT-05a | Departure is not source observation time | FAIL | Departure is mapped to found_at |
| VT-05b | Equivalent UTC and offset timestamps | FAIL | Same instant loses offset; 50 h quote wrongly fresh |
| VT-05c | Unknown and future source metadata | FAIL | Unknown source time invented; future accepted as fresh |
| VT-11 | Operator authorization | FAIL | No authorization; 12 snapshots written |
| VT-08 | Alert input validation | FAIL | Missing route 500; past date 200; negative threshold 422 |
| VT-06 | Replayed source observation | FAIL | Replay creates two rows |
| VT-09a | Repeated threshold state update suppression | PASS | First qualifying state update 1; replay 0; not push delivery |
| VT-04 | History departure-date isolation | FAIL | Two departure dates returned |
| VT-07b | Prior median excludes current | FAIL | Median 15000; expected prior-only 10000 |
| VT-12a | Reject invalid quote money | FAIL | Negative, NaN and infinity accepted |
| VT-14-local | Local history latency characterization | PASS | p95 42.81 ms; median 14.15 ms; local SQLite only |

The nine Python source files also passed syntax parsing. Exact monetary database persistence, secret-log auditing, rollback, real push delivery, PostgreSQL setup and a clean installation are not established. Source integrity failures map to [#20](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/20), history/baseline failures to [#21](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/21), and authorization/alert validation to [#22](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/22).

## Flutter outcomes

Flutter 3.47.5 / Dart 3.13.4: 17 tests passed, static analysis reported no issues, and the release Web build succeeded. Eight model/API tests cover prior median, exact hundredths, invalid amounts, metadata, demo isolation, route/date filtering, HTTP error and past date. Five preference tests cover recreation, independent dates, mode isolation, rapid writes and corrupt storage. Four widget tests cover threshold management, distinct data/error states, date validation, search/favorites and a narrow layout with text scale 1.6.

Browser inspection at 390 by 844 verified date, favorite and rule restoration after page reload and distinguished missing/error states. Rules remain device-local; a saved rule is not a server alert or delivered notification. No live market price, forecast accuracy, native build or usability study is established. Full Flutter checks were performed during the preceding prototype update on 24 October; this results document records those checks rather than claiming another rerun.

## Reproducing the backend diagnostics

Obtain the declared backend revision in a separate checkout. In the documentation checkout, create a disposable environment and install the pinned verification dependencies. This is an offline diagnostic script, not a production collector. Do not supply real tokens. Example commands are from the documentation repository root; substitute the actual backend checkout path.

```sh
python -m venv .verification-venv
# Activate .verification-venv using your platform's normal command.
python -m pip install -r docs/evidence/backend-check-requirements.txt
python docs/evidence/check_backend.py --backend-root /path/to/backend-checkout/backend --source-commit 4c16b32647e9dc780eec368a4ce20f015986c539 --output backend-results-local.json
```

The runner reads the supplied backend source and uses a temporary DB. `source-commit` is a declared identifier; compare file hashes with the published JSON to verify that it matches. External sockets are rejected except loopback used by Windows asyncio. Exit code zero means the run completed; inspect FAIL counts. Current source is expected to reproduce failures. Rerun after repairs with the new revision and output filename. Fresh installs and PostgreSQL are separate checks, not implied by the recorded environment.

## Unexecuted human and deployment checks

No real user discussions or supervisor comments are supplied. Do not fill completion rates, participant counts or approval with demonstration values. Native Android/iOS, screen-reader behavior, controlled live coverage, source permission/quotas, server alert delivery, production performance and chronological ML accuracy remain unverified. See [the plan](VERIFICATION_PLAN.md) and [management register](PROJECT_PLAN.md) for owners and release gates.
