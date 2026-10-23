# Architecture and diagrams

**Status:** draft architecture, prepared 23 October 2026; peer/supervisor review pending.  
**Related issues:** [#5](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/5), [#12](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/12)

## System Context Diagram

![System context](diagrams/system-context.svg)

Editable source: [system-context.puml](diagrams/system-context.puml).

The product boundary includes the intended mobile application and supporting backend. Travelers use the mobile client; an operator controls collection. External source access and push delivery are dependencies. A Flutter/Dart demo client now exists under `mobile/`; production backend integration, native builds and push delivery remain unverified. The diagrams' planned mobile labels describe the intended production integration; the demo is not that completed integration.

## Use Case Diagram

![Use cases](diagrams/use-cases.svg)

Editable source: [use-cases.puml](diagrams/use-cases.puml).

The traveler selects route/date (FR-01/02), views history and freshness (FR-04/05), inspects assessment (FR-06), configures tracking (FR-07), and receives a qualifying alert (FR-08). Loading/missing/error behavior (FR-09) applies across these scenarios. The operator runs controlled collection (FR-03). Receipt of notifications is planned; operator authorization is not currently enforced.

## Draft Component Diagram

![Components](diagrams/components.svg)

Editable source: [components.puml](diagrams/components.puml).

| Component | Responsibility | Current state |
| --- | --- | --- |
| Mobile client | Route/history/assessment presentation and local demo threshold | Flutter Web demo available; date picker, native builds and production integration pending |
| FastAPI | API routing, validation and persistence access | Published prototype |
| Collector | Provider request, normalization, snapshot write, threshold checks | Published prototype with data-trust defects |
| Analytics | Median and linear assessment | Published baseline, not validated prediction |
| PostgreSQL | Routes, snapshots and alert-rule state | Models and Compose configuration exist; deployment unverified |
| Scheduler | Bounded repeat collection and run tracking | Planned |
| Push adapter/provider | Delivery attempts/results and device notifications | Planned |
| External source adapter | Current request code targets Travelpayouts | Live access/coverage not verified |

## Data flow

1. At startup the backend creates tables and initializes the 12 candidate directions.
2. A controlled operator action should select collection targets; the current endpoint selects one future date for all active directions.
3. The source adapter returns a quote, missing data, or an error. The intended design preserves these distinct outcomes and unknown metadata.
4. Valid observations are normalized, assigned provenance and stored by route/departure date.
5. Read APIs supply the client with history, timestamps and assessment.
6. A tracking rule is checked against a qualifying new observation; actual delivery must be recorded separately from threshold evaluation.

Current code violates step 3 by generating fallback quotes and has timestamp defects. Step 6 currently updates state but does not send a push. Diagram arrows describe responsibilities and intended interaction, not deployment or successful delivery.

## Interfaces and current gaps

The published API has routes, collect, history, analytics and alert creation endpoints; see the repository README for paths and current behavior. The history endpoint needs a departure-date filter. Alert management needs deactivation and route validation. Collection needs controlled access, source identities and real/simulated separation. No client-to-provider credentials should be exposed.

## Storage relationships

One Route has many PriceSnapshots and many PriceAlerts. Existing snapshots store route ID, departure date, amount, carrier/flight metadata, source/collection time, freshness and booking horizon. Planned improvements include exact monetary types, source identity, collection-run outcomes and delivery evidence. This is a description of the published models, not an applied migration.
