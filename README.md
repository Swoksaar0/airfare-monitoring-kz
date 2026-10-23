# Airfare Monitoring KZ

Development of a mobile application for monitoring and analyzing airfare dynamics on selected domestic routes in Kazakhstan.

## Diploma topic

- **English:** Development of a Mobile Application for Monitoring and Analyzing Airfare Dynamics on Domestic Routes in Kazakhstan.
- **Русский:** Разработка мобильного приложения для мониторинга и анализа динамики цен на авиабилеты по внутренним маршрутам Казахстана.
- **Қазақша:** Қазақстанның ішкі әуе бағыттары бойынша авиабилеттер бағасының динамикасын бақылауға және талдауға арналған мобильді қосымшаны әзірлеу.

**Current stage:** backend prototype, a Flutter/Dart demo client, and initial project planning. A complete mobile application and a validated airfare prediction model are not yet available in this repository.

## Project links

- [Checkpoint documentation drafts and diagrams](docs/README.md)

- [Repository](https://github.com/Swoksaar0/airfare-monitoring-kz)
- [GitHub Projects board](https://github.com/users/Swoksaar0/projects/2/views/1)
- [All project issues](https://github.com/Swoksaar0/airfare-monitoring-kz/issues)
- [Dinmukhammed's issues](https://github.com/Swoksaar0/airfare-monitoring-kz/issues?q=is%3Aissue+assignee%3ASwoksaar0)
- [Bekbauly's issues](https://github.com/Swoksaar0/airfare-monitoring-kz/issues?q=is%3Aissue+assignee%3ABekbauly)
- [Primary Flutter/Dart prototype and launch instructions](mobile/README.md) — explicit demo mode; [issue #6](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/6).
- [Earlier browser UI reference](docs/prototype/README.md) — optional visual sketch.

## Problem, target users, and relevance

The project investigates how repeated observations of domestic airfare quotes can help travelers understand price changes for a selected route and departure date.

The intended users are people who plan flights within Kazakhstan and want to review the available price history, understand when a quote was collected, and set a price threshold for tracking.

The initial design assumes that these capabilities would be useful. This assumption still needs evidence from 3–5 real discussions with potential users. Interview findings, comparisons with existing services, and literature-review results have not yet been published. The project does not claim that all existing booking services lack these capabilities.

## Aim and objectives

**Aim:** develop and evaluate a mobile application supported by a data-collection backend that stores airfare observations and presents their dynamics on selected domestic routes.

Objectives:

1. Confirm user needs and define testable functional and non-functional requirements.
2. Select 10–15 directional domestic routes and verify data availability for the selected route/date combinations.
3. Collect and store repeated observations while distinguishing the departure date, collection time, and source price timestamp when available.
4. Provide a server API for routes, price history, statistical assessment, and tracking rules.
5. Design and implement a mobile interface for route/date selection, price history, and tracking.
6. Implement threshold notifications with duplicate suppression and verifiable delivery behavior.
7. Compare statistical or ML approaches with a simple baseline, using evaluation that respects the order of observations in time.
8. Evaluate data quality, application behavior, and the usefulness of the main user scenarios.

## Expected outcomes

The intended final deliverables are a mobile application, a backend API, a documented database, an observation dataset with known provenance, price-history views, a notification mechanism, and an evaluation report.

The backend files currently present are an initial implementation toward these outcomes. The existence of code is not evidence of deployment, reliable live collection, delivered notifications, or model accuracy.

## Team and responsibilities

| Team member | GitHub account | Main responsibilities |
| --- | --- | --- |
| Bekbauly | [@Bekbauly](https://github.com/Bekbauly) | Data sources, backend API, database, collection pipeline, statistical analysis, and ML experiments |
| Dinmukhammed | [@Swoksaar0](https://github.com/Swoksaar0) | User research, requirements, mobile UX/UI, mobile client, visualization, and notification functionality |

Both students contribute to architecture, integration, verification, documentation, and review of each other's changes.

**Academic supervisor:** Senior Lecturer Arailym Zhanbolatkyzy Orazova.

## Scope

### First version

- 10–15 selected **directional** domestic routes; the current seed list contains 12.
- A → B and B → A count as separate monitoring directions.
- One-way searches and prices in KZT in the current collector.
- Price history grouped by route **and departure date**.
- Explicit presentation of unknown values, missing observations, errors, and data freshness.
- Android as the initial mobile target; Flutter/Dart is the selected implementation technology, with a Web demo now available.
- Statistical assessment before any claim of a useful predictive model.

### Outside the first version

Ticket booking, payment, guaranteed coverage of all domestic flights or fare families, real-time inventory, and guaranteed advice about the best purchase date are outside the scope.

Source availability and coverage must be verified experimentally. Having a route in the seed list does not mean that real fares have already been collected for it.

## Implementation status

Status reflects the published backend inspected on **23 October 2026**.

| Component | Status | Evidence or limitation |
| --- | --- | --- |
| Repository and task backlog | Present | 16 assigned issues with expected outcomes, deadlines, and acceptance criteria |
| PostgreSQL configuration | Present in code | Docker Compose defines PostgreSQL 16; actual deployment is not established by the configuration alone |
| Database models | Implemented prototype | `Route`, `PriceSnapshot`, and `PriceAlert` |
| FastAPI endpoints | Implemented prototype | Health, routes, collection, history, analytics, and alert-rule creation |
| Route initialization | Implemented | Seeds 12 directional routes at application startup |
| Travelpayouts integration | Partial | Request code exists; an absent token, provider error, or empty result can silently produce simulated quotes |
| Freshness handling | Requires correction | Provider departure time is currently mapped to source price time; missing metadata can also be invented |
| Statistical analysis | Implemented baseline | Median and a simple linear estimate; no validated performance results |
| Alert handling | Partial | Threshold checks and notification-state updates exist; actual push delivery is absent |
| Scheduled collection | Not implemented | Collection is invoked through an API endpoint |
| SCAT parser integration | Not present in this repository | The published collector does not call a SCAT parser |
| Mobile application and clickable prototype | Flutter demo available; native builds/integration unverified | [Flutter source, tests and launch instructions](mobile/README.md); earlier HTML sketch retained as a visual reference |
| Automated tests and CI | Two Flutter checks available; backend regression suite/CI pending | [Flutter checks](mobile/README.md); backend diagnostic review below |
| Requirements, research, and architecture documents | Pending | Tracked in the linked issues |

## Data-source limitations that affect the current prototype

The following behavior must be corrected before the collected values can be presented as a trustworthy live airfare dataset:

1. **Silent simulation fallback.** With an empty `TRAVELPAYOUTS_TOKEN`, an API exception, or no returned offers, the collector generates a random price, carrier, flight number, and source timestamp. Stored snapshots do not contain a field distinguishing these simulated values from real quotes.
2. **Incorrect source timestamp.** The API adapter maps `departure_at` into `found_at`. A departure timestamp is not evidence of when the price was observed. Future timestamps may therefore pass the freshness check.
3. **Unknown metadata is filled in.** Normalization can substitute a carrier, flight number, and random timestamp when they are missing. Unknown data should instead remain unknown.
4. **Time-zone offsets are discarded.** The current conversion removes the offset without first converting the instant to UTC, which can change the calculated quote age.
5. **Repeated observations are not identified.** Recollecting the same provider quote appends another row. Such rows must not automatically be counted as independent price changes or ML examples.
6. **History can mix departure dates.** The history endpoint currently filters by route but does not expose a departure-date filter. A graph for one departure date must not mix these observations.
7. **Collection access is unrestricted.** The collection endpoint has no authentication or rate limiting. It is intended for controlled local development at this stage.

The current configuration has an empty provider token. Do not treat prices generated by this configuration as observed market prices or use them to report real prediction accuracy.

The analytics baseline also includes the current observation in its reported historical median. For a comparison against prior history, the baseline must be computed from prior observations only. A statistical label or a linear estimate is not a validated future-price forecast.

## Initial route list

These are seed directions, not a verified coverage report.

| Origin | Destination | Direction |
| --- | --- | --- |
| ALA | NQZ | Almaty → Astana |
| NQZ | ALA | Astana → Almaty |
| ALA | CIT | Almaty → Shymkent |
| ALA | SCO | Almaty → Aktau |
| ALA | GUW | Almaty → Atyrau |
| ALA | AKX | Almaty → Aktobe |
| NQZ | CIT | Astana → Shymkent |
| NQZ | SCO | Astana → Aktau |
| NQZ | GUW | Astana → Atyrau |
| NQZ | AKX | Astana → Aktobe |
| NQZ | UKK | Astana → Oskemen |
| ALA | KGF | Almaty → Karaganda |

## Architecture and data flow

Current flow:

1. FastAPI initializes the tables and seeds routes when the application starts.
2. A manual `POST /api/v1/collect` call selects one future departure date for all active routes.
3. The collector requests the provider when a token is configured, or follows its current simulation fallback.
4. Normalized values are stored in PostgreSQL as price snapshots.
5. The collector evaluates matching alert rules and updates their notification-state fields.
6. Read endpoints provide route lists, snapshot history, and statistical assessment.

The mobile client, scheduler, and push-delivery integration are planned components.

```mermaid
flowchart LR
    Operator["Developer / operator"] -->|"manual collection"| API["FastAPI"]
    Mobile["Planned mobile client"] -.->|"read data / create tracking rule"| API
    API --> Collector["Collector"]
    Collector --> Provider["Travelpayouts request adapter"]
    Collector --> Demo["Current simulation fallback"]
    Provider --> Collector
    Demo --> Collector
    Collector --> DB[("PostgreSQL")]
    API --> Analytics["Median / linear baseline"]
    Analytics --> DB
    API --> DB
```

This overview does not replace the required System Context, Use Case, and draft Component diagrams with editable sources.

## Database entities

| Entity | Main fields and purpose |
| --- | --- |
| `routes` | Origin/destination IATA codes and city names, activity flag; origin/destination pair is unique |
| `price_snapshots` | Route, departure date, price in KZT, carrier/flight metadata, transfers, source time, collection time, freshness flag, and days before departure |
| `price_alerts` | Device token, route, departure date, price threshold, activity flag, last notified price, and last notified time |

Relationships: one route has many snapshots and many alert rules.

Current limitations include floating-point money fields, no observation identity constraint, no explicit real/simulated source marker, and no delivery log. These models describe the current published backend; migrations and historical data imports are not provided.

## Technologies

| Area | Current or planned choice | Status |
| --- | --- | --- |
| Backend | Python, FastAPI, Uvicorn | Present |
| Validation/configuration | Pydantic, Pydantic Settings | Present |
| Persistence | PostgreSQL 16, SQLAlchemy, Psycopg2 | Configuration and models present |
| HTTP integration | HTTPX | Present |
| Analytics | Python statistics and a simple least-squares calculation | Present |
| Mobile | Flutter/Dart, Material 3 and CustomPainter | Web demo built and checked; native targets pending |
| Project management | GitHub Issues and GitHub Projects | In use |

The dependency file currently does not pin versions. A reproducible dependency set and a comparison of alternatives for at least three technical decisions remain to be completed in [issue #11](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/11).

## Published repository structure

```text
airfare-monitoring-kz/
├── .gitignore
├── README.md
├── docs/                    # Checkpoint drafts, diagrams and earlier HTML reference
├── mobile/                  # Flutter/Dart demo, Web launcher and two checks
└── backend/
    ├── .env
    ├── docker-compose.yml
    ├── requirements.txt
    └── app/
        ├── __init__.py
        ├── config.py
        ├── database.py
        ├── models.py
        ├── schemas.py
        ├── main.py
        └── services/
            ├── __init__.py
            ├── collector.py
            └── analytics.py
```

At the time of review, `.gitignore` is empty and `backend/.env` is tracked. Configuration hygiene needs an update: provide an `.env.example`, ignore local `.env` files and virtual environments, and keep real credentials out of Git history.

The `docs/` directory contains checkpoint drafts, editable diagram sources, readable SVG exports, evidence templates, and a browser-based clickable mobile-interface prototype. They require peer/supervisor review. The `mobile/` directory contains the Flutter/Dart client, Web launcher and `mobile/test/` checks. Backend automated tests and native platform launch folders remain outstanding.

## Running the backend locally

### Prerequisites

- Python 3.11 or newer; use an isolated virtual environment.
- Docker with Docker Compose available.
- Git for cloning.
- Port 5433 available for the development PostgreSQL instance and port 8000 for FastAPI.

The instructions below describe the intended PostgreSQL setup. A successful Docker/PostgreSQL deployment has not been established by the current repository review.

### Windows PowerShell

Run from a directory where you want a new checkout:

```powershell
git clone https://github.com/Swoksaar0/airfare-monitoring-kz.git
cd airfare-monitoring-kz/backend

py -3.12 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt

docker compose up -d
docker compose exec postgres pg_isready -U kz_user -d kz_flights

.\.venv\Scripts\python.exe -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
```

If Python 3.12 is not installed, use the launcher for an installed supported version. Start Uvicorn after PostgreSQL reports that it is accepting connections.

### Linux / macOS

```bash
git clone https://github.com/Swoksaar0/airfare-monitoring-kz.git
cd airfare-monitoring-kz/backend

python3 -m venv .venv
.venv/bin/python -m pip install -r requirements.txt

docker compose up -d
docker compose exec postgres pg_isready -U kz_user -d kz_flights

.venv/bin/python -m uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload
```

### Configuration

Settings are loaded from environment variables and a `.env` file in the current working directory. Run the backend from `backend/`.

The existing local-development database settings match Docker Compose:

```dotenv
DATABASE_URL=postgresql+psycopg2://kz_user:kz_password@127.0.0.1:5433/kz_flights
TRAVELPAYOUTS_TOKEN=
CACHE_FRESHNESS_HOURS=48
```

The database credentials above are development examples. An empty provider token activates the current simulation fallback. Supplying a real token does not fix the timestamp and source-separation problems listed earlier.

The application connects to the database during module import and creates tables with `Base.metadata.create_all`. It does not currently provide a migration command.

### Service URLs

- [Swagger UI](http://127.0.0.1:8000/docs)
- [OpenAPI schema](http://127.0.0.1:8000/openapi.json)
- [Health check](http://127.0.0.1:8000/health)

See [mobile/README.md](mobile/README.md) for Flutter demo launch, verification commands and limitations. This mode uses synthetic client-only data without calling the backend or airfare providers.

## API endpoints

| Method | Endpoint | Current behavior |
| --- | --- | --- |
| GET | `/health` | Returns application status and version |
| GET | `/api/v1/routes` | Returns active routes |
| POST | `/api/v1/collect?days_ahead=7` | Collects or simulates one quote for each active route; allowed horizon is 1–60 days |
| GET | `/api/v1/routes/{route_id}/history?only_fresh=true` | Returns stored snapshots ordered by collection time; may include different departure dates |
| GET | `/api/v1/routes/{route_id}/analytics?departure_date=YYYY-MM-DD` | Returns the current quote, median, linear estimate, and qualitative assessment |
| POST | `/api/v1/alerts` | Creates a tracking rule; does not send a push notification |

The collector runs sequentially. With 12 active routes and a configured token, one invocation can send up to 12 provider requests. No daily scheduler is included.

The history response currently omits `flight_number`, although the database model stores it. Creating an alert does not yet validate that its referenced route exists at the application layer.

## Verification and testing

There is no committed automated test suite or CI workflow yet. Implementing the verification plan is tracked in [issue #14](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/14).

### Backend review performed on 23 October 2026

The backend source at commit `5c4d52efb5b6076d9cffc8fbff93e9691a3f360b` was inspected and exercised in an isolated Python 3.12.14 environment. Checks used a disposable SQLite database with foreign-key enforcement and mocked provider responses. **No live requests were sent to airlines or Travelpayouts.**

Nine Python files passed syntax parsing. Twelve diagnostic scenarios were exercised; these are characterization checks, not a claim that the backend has passed acceptance testing.

| Scenario | Observed result |
| --- | --- |
| Startup, health, and route list | Health and routes returned HTTP 200; 12 routes were seeded |
| Analytics without observations | HTTP 200 with `INSUFFICIENT_DATA` |
| Missing provider token | A generated quote was returned without a source/simulation marker |
| Collection without authentication | HTTP 200; 12 generated snapshots were stored |
| Provider connection failure | A generated price was returned instead of a collection error |
| Provider timestamp mapping | Departure time became source price time and was marked fresh |
| Missing source metadata | A timestamp, carrier `KC`, and flight number `101` were substituted |
| Time-zone conversion | A 50-hour-old quote expressed with a +05:00 offset passed the 48-hour freshness limit |
| Alert validation | Valid rule: HTTP 200; negative threshold: HTTP 422; unknown route: HTTP 500 |
| Repeated source quote | Two rows were stored; the first threshold crossing updated alert state and the identical second quote did not trigger another state update |
| Route history | Observations for two departure dates were returned together; flight number was absent from the response |
| Historical median | Prior price 10,000 and current price 20,000 produced median 15,000, showing inclusion of the current observation |

The review did not establish PostgreSQL deployment, real provider access, live price coverage, push delivery, or mobile behavior. The diagnostic runner is not part of the published test suite. A committed regression suite remains an engineering task.

### Read-only smoke checks

After starting the server, use another PowerShell terminal:

```powershell
Invoke-RestMethod http://127.0.0.1:8000/health
$routes = Invoke-RestMethod http://127.0.0.1:8000/api/v1/routes
$routes | Format-Table id,origin_iata,destination_iata
```

On a new database, the route endpoint should return the 12 seed directions. Read the returned IDs rather than assuming a particular database ID.

### Optional demonstration collection

The following operation writes snapshots and evaluates alert rules. With the currently empty token, generated prices are simulated. With a token configured, it can contact the provider.

```powershell
Invoke-RestMethod -Method Post 'http://127.0.0.1:8000/api/v1/collect?days_ahead=7'

$routeId = $routes[0].id
$departureDate = (Get-Date).Date.AddDays(7).ToString('yyyy-MM-dd')
Invoke-RestMethod "http://127.0.0.1:8000/api/v1/routes/$routeId/history?only_fresh=false"
Invoke-RestMethod "http://127.0.0.1:8000/api/v1/routes/$routeId/analytics?departure_date=$departureDate"
```

A successful HTTP response demonstrates endpoint behavior, not genuine live fares or source freshness.

### Planned evaluation

- Data collection: verified route/date coverage, provider failures, missing observations, distinct source observations, and trustworthy freshness.
- Storage: preservation of provenance, handling of repeated source quotes, and separation of synthetic data.
- API: validation, error responses, route/date filtering, and access controls for collection.
- Analytics: median and linear estimates compared with a simple baseline on a time-ordered holdout; report errors such as MAE only when suitable real observations exist.
- Mobile UX: completion of the main scenarios, loading/error states, and understanding of freshness indicators.
- Alerts: threshold behavior, duplicate suppression, actual delivery results, and recovery after failures.

No accuracy, usability, coverage, or latency results are claimed yet.

## Documentation and deliverables for 24 October

| Deliverable | Status / task |
| --- | --- |
| Proposal and scope | Initial overview in this README; full reviewed proposal pending in [#1](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/1) |
| Evidence of relevance | 3–5 real user discussions pending in [#2](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/2) |
| Existing-system comparison | 3–5 systems and 6–10 criteria; [#3](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/3) |
| Functional/non-functional requirements | IDs, priorities, and acceptance criteria; [#4](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/4) |
| Use Case Diagram | Editable source and export; [#5](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/5) |
| Clickable prototype | [Flutter demo](mobile/README.md) and [earlier UI reference](docs/prototype/README.md), awaiting review; [#6](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/6) |
| Literature review | At least 12 distinct sources including 8 scientific publications; [#7](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/7) and [#13](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/13) |
| Milestones, risks, and dependencies | [#8](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/8) |
| README and repository organization | [#9](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/9) |
| Collection and storage documentation | [#10](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/10) |
| Technology comparison | At least 3 decisions with 2–3 alternatives each; [#11](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/11) |
| Context and Component Diagrams | Editable sources and exports; [#12](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/12) |
| Verification/evaluation plan | Metrics, conditions, checks, and baseline; [#14](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/14) |
| Supervisor feedback | Actual comments and actions; [#15](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/15) |
| Reviewed submission | Links, limitations, remaining tasks, and `pre-defense-1` tag; [#16](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/16) |

A complete mobile application is not required for this checkpoint. Analysis, design, planning, individual contributions, and substantive supervisor review still need to be evidenced.

## Planned milestones, risks, and dependencies

| Milestone | Expected result | Main dependency |
| --- | --- | --- |
| First checkpoint | Reviewed proposal, research, requirements, diagrams, prototype, and evaluation plan | User discussions and supervisor feedback |
| Trustworthy data pilot | Real/synthetic separation, corrected timestamps, verified provider coverage, and repeat-observation handling | Suitable source access and reliable metadata |
| Mobile/backend integration | Agreed API contract, route/date-specific history, UI states, and tracking-rule management | Published mobile prototype and stable backend behavior |
| Analytics experiment | Reproducible baseline comparison on real time-ordered observations | Sufficient distinct observations accumulated over time |
| Final evaluation | Tested application, verified notification delivery, measured results, and documented limitations | Integration, user testing, and review |

Key risks are provider restrictions or missing coverage, unsuitable or stale cached data, insufficient observation history, dependence on a short collection period, and integration delays. Mitigations include a small coverage pilot, explicit missing/error states, early data collection after correctness fixes, a simple baseline, and a shared API contract.

These are planned milestones; they do not assert completion or replace agreed deadlines in the task board.

## Collaboration and submission workflow

Each student uses an identifiable personal GitHub account.

For each meaningful work item:

1. Use an issue with one responsible student, expected outcome, acceptance criteria, priority, and deadline.
2. Develop the deliverable in a task branch and reference the issue number in the change description.
3. Submit a pull request explaining the change and how it was checked.
4. Have the other student review the work and record resulting changes.
5. Attach the deliverable or pull request to the issue and mark it complete only after acceptance and review.

Deadlines and priorities currently appear in issue descriptions; corresponding project fields still need consistent configuration.

Before submission, review the exact revision and create the required `pre-defense-1` tag. No existing release tag is claimed by this README.

## Next engineering priorities

1. Separate demonstration mode from live collection and preserve errors instead of silently replacing missing fares.
2. Correct source timestamps, unknown metadata, and UTC conversion.
3. Define observation identity, route/date-specific history, and data-quality checks.
4. Add input validation, controlled collection access, automated tests, and reproducible dependencies.
5. Publish the mandatory documents, diagrams, and clickable prototype.
6. Implement and evaluate the mobile client and actual notification delivery.
