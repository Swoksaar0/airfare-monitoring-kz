# KZ Domestic Flights Price Monitor & Analytics

Diploma thesis project developed by **Software Engineering** students (Group SE-2419).

A client-server application designed for systematic monitoring, collecting historical minimal airfares, predicting fair booking values, and delivering verified push alerts across key domestic flight routes within the Republic of Kazakhstan.

---

## Problem Statement & Project Value

The domestic air travel market in Kazakhstan is characterized by a high market concentration (Air Astana, FlyArystan, SCAT, Qazaq Air) and dynamic pricing algorithms. Passengers frequently experience sharp fare volatility driven by booking horizon (days before departure), seasonality, and load factors.

Existing commercial aggregators are designed for immediate booking rather than longitudinal price tracking, exhibiting several key limitations:

1. **Cache Staleness:** Public flight search APIs often serve cached fare quotes with latencies ranging from several hours to multiple days.
2. **Lack of Transparent Statistical Baselines:** Users are not provided with localized median benchmarks to determine whether a fare is truly discounted, typical, or overpriced.
3. **Alert Fatigue / Notification Spam:** Standard notification services trigger alerts on any minor price fluctuation, ignoring thresholds and creating duplicate messages.

**Our Approach:**

* Scheduled ingestion and normalization of domestic airfare snapshots with cache freshness validation (`is_fresh`).
* Estimation of historical median baselines and rolling linear trends without future data leakage.
* An intelligent client alert engine featuring threshold verification and notification deduplication to prevent repetitive alerts for the same price level.

---

## Team & Responsibilities

| Contributor | Role & Domain Ownership | YouTrack Tasks |
| --- | --- | --- |
| **Galymzhan Bekbauly** | **Backend, Data Engineering & ML**<br>

<br>• Relational PostgreSQL schema and SQLAlchemy models<br>

<br>• RESTful API service built with FastAPI<br>

<br>• Data ingestion pipeline with cache-age filtering<br>

<br>• Mathematical baseline engine (historical median & linear regression) | `KZF-1`<br>

<br>`KZF-2`<br>

<br>`KZF-3`<br>

<br>`KZF-4` |
| **Dinmukhammed Yessenkhosov** | **Mobile, UI/UX & Alerts System**<br>

<br>• Cross-platform mobile client built with Flutter (Dart)<br>

<br>• Interactive price history chart views (`fl_chart`)<br>

<br>• "Favorites" routes management module<br>

<br>• Threshold checking and alert deduplication service | `KZF-5`<br>

<br>`KZF-6`<br>

<br>`KZF-7`<br>

<br>`KZF-8` |

**Academic Supervisor:** Senior Lecturer Arailym Zhanbolatkyzy Orazova.

---

## Tech Stack

* **Backend:** Python 3.11+, FastAPI, Uvicorn, Pydantic v2, Pydantic-Settings, HTTPX.
* **Database:** PostgreSQL 16 (containerized via Docker Compose), SQLAlchemy 2.0 ORM, Psycopg2-binary.
* **Analytics & Modeling:** Historical median baselines, linear regression models, pipeline preparation for gradient boosting (LightGBM / CatBoost).
* **Mobile Client:** Flutter 3.x, Dart, `fl_chart`, service-based state and clean separation of concerns.
* **Tooling & Project Management:** Git, GitHub, YouTrack (Agile / Scrum).

---

## Tracked Domestic Routes (12 Kazakhstan Pairs)

1. **ALA ↔ NQZ:** Almaty — Astana
2. **NQZ ↔ ALA:** Astana — Almaty
3. **ALA ↔ CIT:** Almaty — Shymkent
4. **ALA ↔ SCO:** Almaty — Aktau
5. **ALA ↔ GUW:** Almaty — Atyrau
6. **ALA ↔ AKX:** Almaty — Aktobe
7. **NQZ ↔ CIT:** Astana — Shymkent
8. **NQZ ↔ SCO:** Astana — Aktau
9. **NQZ ↔ GUW:** Astana — Atyrau
10. **NQZ ↔ AKX:** Astana — Aktobe
11. **NQZ ↔ UKK:** Astana — Ust-Kamenogorsk
12. **ALA ↔ KGF:** Almaty — Karaganda

---

## Repository Structure

```text
kz-flights-monitor/
├── .gitignore                      # Git exclusion rules (.venv, cache, IDE)
├── README.md                       # Project overview and runbook
│
├── docs/                           # Project documentation & specifications
│   ├── ARCHITECTURE.md             # System components & API specifications
│   └── USE_CASES.md                # User scenarios and interaction flows
│
├── backend/                        # Server application (FastAPI + PostgreSQL)
│   ├── docker-compose.yml          # PostgreSQL 16 container definition
│   ├── requirements.txt            # Python dependencies
│   ├── .env.example                # Environment variables template
│   └── app/
│       ├── config.py               # Pydantic-Settings application configuration
│       ├── database.py             # SQLAlchemy engine & session maker
│       ├── models.py               # Database ORM models (routes, snapshots, alerts)
│       ├── schemas.py              # Pydantic validation schemas / DTOs
│       ├── main.py                 # FastAPI application router & endpoints
│       └── services/
│           ├── collector.py        # Fare collection & cache freshness validation
│           └── analytics.py        # Historical median & linear model evaluation
│
└── mobile/                         # Mobile client application (Flutter)
    ├── pubspec.yaml                # Flutter dependencies (fl_chart, http)
    └── lib/
        ├── main.dart               # Application entry point
        ├── models/                 # Client domain data models
        ├── services/               # API service, favorites, and alert engine
        └── screens/                # Route list, detail, and analytics UI screens

```

---

## Quick Start & Local Setup

### 1. Backend & Database Setup

```bash
cd backend

docker compose up -d

python -m venv .venv
.\.venv\Scripts\activate
source .venv/bin/activate

pip install --upgrade pip
pip install -r requirements.txt

uvicorn app.main:app --reload

```

Server endpoints will be available at:

* **Interactive Swagger UI:** [http://127.0.0.1:8000/docs](https://www.google.com/search?q=http://127.0.0.1:8000/docs)
* **Health Check:** [http://127.0.0.1:8000/health](https://www.google.com/search?q=http://127.0.0.1:8000/health)

### 2. Mobile Client Setup

```bash
cd mobile

flutter pub get

flutter run

```

---

## Milestone Deliverables (`prob-period-1`)

The following deliverables have been achieved for the first probation period:

1. Deployed containerized PostgreSQL 16 with relational schemas across `routes`, `price_snapshots`, and `price_alerts`.
2. Implemented a pilot data ingestion pipeline for 12 Kazakhstan domestic routes with departure horizon calculation (`days_before_departure`) and cache freshness validation (`is_fresh`).
3. Built and tested an analytics endpoint providing qualitative fare evaluation (`LOW`, `TYPICAL`, `HIGH`) against historical median baselines.
4. Structured the Flutter mobile client with domestic routes overview, chart visualization components, and an alert deduplication service.
5. Pinned the milestone git release tag: `prob-period-1`.
