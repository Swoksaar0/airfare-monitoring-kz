# Technology comparison and selection rationale

**Status:** proposed decisions for peer/supervisor review, 23 October 2026.  
**Related issue:** [#11](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/11).

Compare **three key decisions with three candidates each**. Capabilities below come from official documentation; project fit, migration effort and the resulting choices are engineering judgments based on this repository. No competing implementation, speed test, learning-time measurement or cost benchmark was performed.

## Decision T1 — mobile client

Requirements: route/date input and history (FR-01/02/04), clear demo/error states (FR-09/11), reproducible verification (NFR-05), and a path to Android first.

| Candidate | Documented model | Fit for this project | Trade-off / work required |
| --- | --- | --- | --- |
| **Flutter / Dart — selected** | Shared application code with mobile and Web targets; platform features may require plugins/native integration [F1] / [F2] | Existing Dart source, Material UI, a Web build and 17 passing tests provide a checked starting point | Native build environments and device testing remain necessary; a successful Web build does not verify Android/iOS behavior |
| React Native / JavaScript or TypeScript | React components use Android/iOS native capabilities; native modules/components cover platform integration [R1] / [R2] | Viable for the same route/history/notification scenarios | Would replace the current Dart client and require verifying native libraries; migration effort is inferred, not measured |
| Kotlin Multiplatform, optionally Compose Multiplatform | Can share selected logic and, with Compose, UI; native UI is also possible [K1] | Viable if Kotlin/shared-domain or native-UI integration becomes a priority | Requires choosing a sharing boundary and establishing its platform/build setup; no KMP prototype was implemented here |

**Rationale:** retain Flutter because a checked Dart prototype already exists and the selected requirements do not demonstrate a need to discard it. This is a project-specific reuse decision, not a claim that Flutter is universally faster or more accurate. The HTML sketch is a visual reference, not an alternative application framework.

**Acceptance before treating this decision as validated:** Dinmukhammed reviews the screens and build workflow; both students verify the route/date API contract. Configure the Android SDK and test on a real/emulated target. Only plan an iOS deliverable after establishing the required macOS build environment and device workflow [F2].

## Decision T2 — backend framework

Requirements: typed route/date/threshold inputs, explicit provider outcomes (FR-03/07), API traceability, controlled collection (NFR-03), and repeatable checks (NFR-05).

| Candidate | Documented capability | Fit for this project | Trade-off / work required |
| --- | --- | --- | --- |
| **FastAPI / Python — selected** | Python type-based validation, OpenAPI/JSON Schema, interactive API docs and dependency injection [B1] | Existing backend/collector code can evolve without changing language/framework | The current app still needs collection authorization, truthful source handling and DB validation; framework features do not enable these automatically |
| Django + Django REST framework / Python | Serialization, authentication policies, browsable API and viewsets/routers [B2] | A reasonable alternative if the project needs more Django-centered model/account administration | Would require adapting the existing API/model organization; no Django implementation or migration estimate was measured |
| Express / Node.js | Minimal web/API framework with routing and middleware [B3] | A reasonable choice for a JavaScript/TypeScript server | Schema validation, API contracts and data-access components need explicit choices; replacing the Python backend would add integration/migration work in this project |

**Rationale:** keep FastAPI for the existing small JSON API and Python data/analysis pipeline. Prefer documented DTOs and error outcomes over a framework rewrite. This does not settle scheduling, source permission, credentials, deployment or push delivery; each requires separate implementation and verification.

**Acceptance:** verify validation/authorization with mocked outcomes, map missing records to client errors, and run storage/deployment checks. Current successful offline diagnostics are not proof of trustworthy live data.

## Decision T3 — observation storage

Requirements: exact money and currency (NFR-02), route/date history (FR-04), observation identity (FR-12), and recoverable writes (NFR-04).

| Candidate | Documented storage model | Fit for this project | Trade-off / work required |
| --- | --- | --- | --- |
| **PostgreSQL — selected for the shared backend** | Exact numeric types and CHECK/UNIQUE/foreign-key constraints [D1] / [D2] | Matches existing relational Route → PriceSnapshot/PriceAlert models and Compose configuration | Requires a running DB service, migrations and tested backup/restore; existing Float fields do not become exact money simply because PostgreSQL is selected |
| SQLite — retain for isolated tests / a small local pilot | Embedded storage; local application use is a primary fit; client/server systems suit some centralized/concurrent workloads better [D3] | Disposable tests and a low-overhead, serialized local collector are viable uses | SQLite is not ruled out for a small backend. Revisit only if measured access/concurrency needs justify a shared DB service |
| MongoDB | Embedding/references, schema validation and transaction options [D4] | Flexible provider response documents could fit a document model | Our relational access pattern and existing SQLAlchemy models would need redesign; references, growth and consistency need deliberate handling. This is not a claim that MongoDB lacks transactions |

**Rationale:** retain the repository's PostgreSQL direction for a shared service while keeping SQLite as a useful test/pilot tool. No measured workload proves that PostgreSQL is required for 10–15 directions. The choice follows current schema/reuse and anticipated shared access; revisiting it is legitimate if the pilot supports a simpler deployment.

**Implementation consequences:** choose an exact money representation and currency rules; define observation identity carefully so an identical cached quote is not mistaken for a new independent observation. Test constraints, timezone handling and failure rollback. These are planned changes, not an applied migration.

## Decision summary and current evidence

| Decision | Selected | Evidence currently available | Still required |
| --- | --- | --- | --- |
| T1 | Flutter/Dart | Source in mobile/, static analysis, 17 tests, Web release build and browser persistence checks | Native builds, real API integration, screen-reader/user checks and delivered push |
| T2 | FastAPI/Python | Published endpoints and mocked/offline API diagnostics | Data-trust fixes, authorization, real source pilot, production deployment |
| T3 | PostgreSQL for shared backend; SQLite for isolated tests | ORM/Compose configuration; disposable SQLite used in review | PostgreSQL deployment/migrations and integrity/recovery checks |

The listed checks verify parts of the selected implementation, not a comparative benchmark against the alternatives. The required scientific literature review remains separate.

## Revisit triggers and review

- Revisit T1 if native integrations or device results reveal a requirement that the chosen client cannot reasonably meet.
- Revisit T2 if administration/authentication requirements materially change the server scope.
- Revisit T3 after measuring pilot write/read patterns and deployment effort; do not add distributed infrastructure merely to make the project appear larger.
- Dinmukhammed reviews mobile implications; Bekbauly reviews backend/data implications; both record agreement and any supervisor changes. Review has not yet been recorded.

## Official references

Reviewed 23 October 2026. Documentation supports capability claims; it is not counted as scientific publication evidence.

- [F1 — Flutter FAQ: language, shared targets and plugins](https://docs.flutter.dev/resources/faq).
- [F2 — Flutter setup: target platform environments](https://docs.flutter.dev/install/custom).
- [R1 — React Native core/native components](https://reactnative.dev/docs/next/intro-react-native-components).
- [R2 — React Native native modules/components](https://reactnative.dev/docs/0.85/native-platform).
- [K1 — Kotlin Multiplatform sharing options](https://kotlinlang.org/docs/multiplatform/build-ios-android-app.html).
- [B1 — FastAPI features](https://fastapi.tiangolo.com/features/).
- [B2 — Django REST framework](https://www.django-rest-framework.org/).
- [B3 — Express](https://expressjs.com/).
- [D1 — PostgreSQL 16 numeric types](https://www.postgresql.org/docs/16/datatype-numeric.html).
- [D2 — PostgreSQL 16 constraints](https://www.postgresql.org/docs/16/ddl-constraints.html).
- [D3 — Appropriate uses for SQLite](https://www.sqlite.org/whentouse.html).
- [D4 — MongoDB data-modeling practices, consistency and validation](https://www.mongodb.com/docs/manual/data-modeling/best-practices/).

[F1]: https://docs.flutter.dev/resources/faq
[F2]: https://docs.flutter.dev/install/custom
[R1]: https://reactnative.dev/docs/next/intro-react-native-components
[R2]: https://reactnative.dev/docs/0.85/native-platform
[K1]: https://kotlinlang.org/docs/multiplatform/build-ios-android-app.html
[B1]: https://fastapi.tiangolo.com/features/
[B2]: https://www.django-rest-framework.org/
[B3]: https://expressjs.com/
[D1]: https://www.postgresql.org/docs/16/datatype-numeric.html
[D2]: https://www.postgresql.org/docs/16/ddl-constraints.html
[D3]: https://www.sqlite.org/whentouse.html
[D4]: https://www.mongodb.com/docs/manual/data-modeling/best-practices/
