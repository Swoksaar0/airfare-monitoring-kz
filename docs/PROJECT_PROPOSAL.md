# Project proposal and scope

**Status:** draft, prepared 23 October 2026; peer and supervisor review pending.  
**Related issue:** [#1](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/1)

## Topic

**English:** Development of a Mobile Application for Monitoring and Analyzing Airfare Dynamics on Domestic Routes in Kazakhstan.  
**Русский:** Разработка мобильного приложения для мониторинга и анализа динамики цен на авиабилеты по внутренним маршрутам Казахстана.  
**Қазақша:** Қазақстанның ішкі әуе бағыттары бойынша авиабилеттер бағасының динамикасын бақылауға және талдауға арналған мобильді қосымшаны әзірлеу.

## Team and supervisor

| Member | Account | Engineering responsibility |
| --- | --- | --- |
| Bekbauly | @Bekbauly | Sources, collection, backend, database, analytics and ML experiments |
| Dinmukhammed | @Swoksaar0 | User research, requirements, mobile interface/client, visualization and notification functionality |

Supervisor: Senior Lecturer Arailym Zhanbolatkyzy Orazova, as listed in the repository README. Both students review requirements, interfaces, integration, tests, and documentation.

## Problem and target users

The project investigates whether repeated airfare observations can support understandable price-history views and threshold tracking for people planning domestic flights in Kazakhstan. One search result does not show how an offer has changed over time.

The intended users are travelers selecting a route and departure date, comparing available observed prices, and deciding whether to track an offer. These needs are initial assumptions. Real discussions and a supported comparison of existing services are required; neither the need nor uniqueness of the proposed solution is asserted as already verified.

## Aim

Develop and evaluate a mobile application and supporting backend that collect, retain, and analyze airfare observations for selected domestic directional routes, with explicit data provenance, freshness, and limitations.

## Objectives

1. Collect user evidence and define prioritized, testable requirements.
2. Select 10–15 directional domestic routes and verify source coverage for route/date combinations.
3. Preserve observations with separate departure dates, collection timestamps, and source timestamps when available.
4. Provide a route/date-specific history and statistical assessment through an API.
5. Implement mobile route/date selection, history visualization, and tracking scenarios.
6. Implement threshold checks, duplicate suppression, and verifiable notification delivery.
7. Compare a simple baseline and candidate statistical/ML approaches on time-ordered real observations.
8. Evaluate data quality, functional behavior, and completion of user scenarios.

## Scope and initial route selection

The current backend seeds 12 directions: ALA→NQZ, NQZ→ALA, ALA→CIT, ALA→SCO, ALA→GUW, ALA→AKX, NQZ→CIT, NQZ→SCO, NQZ→GUW, NQZ→AKX, NQZ→UKK, and ALA→KGF. Reverse directions count separately.

These are candidate monitoring directions, not a verified coverage claim. Retain a final set of 10–15 only after the data pilot; record unavailable combinations rather than inventing offers. Current collector parameters are one-way and KZT, with one selected departure date per run and a 1–60-day horizon. The monitoring design should support repeated observations of fixed departure dates as well as explicitly labeled rolling horizons.

Android is the initial mobile target; Flutter/Dart is selected and a Web demo is available in `mobile/`. The title does not promise an iOS release.

Outside scope: booking/payment, complete flight inventory, guaranteed coverage of all carriers/fare families, real-time repricing, and guaranteed advice about the best purchase date.

## Expected deliverables

- Mobile client and scenario prototype.
- Backend API, documented storage model, and controlled collector.
- Real observations with known provenance and explicit missing/error states.
- Route/date-specific history and baseline assessment.
- Threshold tracking with documented delivery/deduplication behavior.
- Requirements, diagrams, research/comparison documents, test plan, measured results, and reproducible submission instructions.

## Current implementation and technical feasibility

Published code contains FastAPI endpoints, PostgreSQL configuration, ORM models, a 12-direction seed list, collection scaffolding, and median/linear assessment. An offline review exercised the API with temporary SQLite and mocked provider responses.

This is a backend prototype. Missing/error API responses currently fall back to unmarked generated quotes; source-time mapping and UTC conversion are incorrect. These defects must be corrected before a real collection pilot or an ML dataset can be trusted. Flutter/Dart source and a Web demo are available, with explicitly synthetic fixtures. Actual push delivery, native builds, a scheduler, backend integration and validated prediction performance are not established.

## Evaluation approach

Link each requirement to checks in [VERIFICATION_PLAN.md](VERIFICATION_PLAN.md). Evaluate source coverage/freshness, distinct observations, storage integrity, API behavior, user scenario completion, and baseline comparison. Define numerical success targets before measurement. No accuracy or usability outcome is claimed yet.

## Review gate

Bekbauly checks technical feasibility and data claims; Dinmukhammed checks scope and user scenarios; the supervisor reviews the substance. Record comments and resulting decisions. This draft remains open until real user evidence and review are attached.
