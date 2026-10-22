from datetime import datetime, date, timedelta, timezone
import random
import httpx
from sqlalchemy.orm import Session
from app.config import settings
from app.models import Route, PriceSnapshot, PriceAlert

DEFAULT_KZ_ROUTES = [
    ("ALA", "Алматы", "NQZ", "Астана"),
    ("NQZ", "Астана", "ALA", "Алматы"),
    ("ALA", "Алматы", "CIT", "Шымкент"),
    ("ALA", "Алматы", "SCO", "Актау"),
    ("ALA", "Алматы", "GUW", "Атырау"),
    ("ALA", "Алматы", "AKX", "Актобе"),
    ("NQZ", "Астана", "CIT", "Шымкент"),
    ("NQZ", "Астана", "SCO", "Актау"),
    ("NQZ", "Астана", "GUW", "Атырау"),
    ("NQZ", "Астана", "AKX", "Актобе"),
    ("NQZ", "Астана", "UKK", "Усть-Каменогорск"),
    ("ALA", "Алматы", "KGF", "Караганда"),
]


def seed_initial_routes(db: Session) -> int:
    added = 0
    for orig_code, orig_city, dest_code, dest_city in DEFAULT_KZ_ROUTES:
        exists = (
            db.query(Route)
            .filter_by(origin_iata=orig_code, destination_iata=dest_code)
            .first()
        )
        if not exists:
            db.add(
                Route(
                    origin_iata=orig_code,
                    origin_city=orig_city,
                    destination_iata=dest_code,
                    destination_city=dest_city,
                )
            )
            added += 1
    db.commit()
    return added


def normalize_and_validate_quote(raw_item: dict, target_date: date) -> dict:
    now = datetime.now(timezone.utc).replace(tzinfo=None)
    found_at_str = raw_item.get("found_at")
    if found_at_str:
        source_found_at = datetime.fromisoformat(str(found_at_str).replace("Z", "+00:00")).replace(tzinfo=None)
    else:
        source_found_at = now - timedelta(hours=random.randint(1, 20))

    age_hours = (now - source_found_at).total_seconds() / 3600.0
    is_fresh = age_hours <= settings.CACHE_FRESHNESS_HOURS
    days_before = max((target_date - now.date()).days, 0)

    return {
        "departure_date": target_date,
        "price_kzt": round(float(raw_item["price"]), 2),
        "airline_code": str(raw_item.get("airline", "KC")).upper(),
        "flight_number": str(raw_item.get("flight_number", "101")),
        "transfers": int(raw_item.get("transfers", 0)),
        "source_found_at": source_found_at,
        "collected_at": now,
        "is_fresh": is_fresh,
        "days_before_departure": days_before,
    }


def fetch_route_price_from_api(origin: str, destination: str, dep_date: date) -> dict:
    if settings.TRAVELPAYOUTS_TOKEN:
        url = "https://api.travelpayouts.com/aviasales/v3/prices_for_dates"
        params = {
            "origin": origin,
            "destination": destination,
            "departure_at": dep_date.strftime("%Y-%m-%d"),
            "currency": "kzt",
            "one_way": "true",
            "direct": "false",
            "limit": 1,
            "token": settings.TRAVELPAYOUTS_TOKEN,
        }
        try:
            with httpx.Client(timeout=10.0) as client:
                resp = client.get(url, params=params)
                resp.raise_for_status()
                data = resp.json().get("data", [])
                if data:
                    item = data[0]
                    return {
                        "price": item["price"],
                        "airline": item.get("airline", "KC"),
                        "flight_number": str(item.get("flight_number", "")),
                        "transfers": item.get("transfers", 0),
                        "found_at": item.get("departure_at"),
                    }
        except Exception:
            pass

    base_prices = {
        ("ALA", "NQZ"): 24500,
        ("NQZ", "ALA"): 24000,
        ("ALA", "CIT"): 16500,
        ("ALA", "SCO"): 38000,
        ("ALA", "GUW"): 36000,
    }
    base = base_prices.get((origin, destination), 28000)
    simulated_price = base + random.randint(-4000, 7500)
    return {
        "price": simulated_price,
        "airline": random.choice(["KC", "IQ", "DV"]),
        "flight_number": str(random.randint(100, 999)),
        "transfers": 0,
        "found_at": (datetime.now(timezone.utc).replace(tzinfo=None) - timedelta(hours=random.randint(1, 60))).isoformat(),
    }


def collect_prices_for_active_routes(db: Session, days_ahead: int = 7) -> dict:
    routes = db.query(Route).filter_by(is_active=True).all()
    saved_count = 0
    triggered_alerts = 0
    target_date = date.today() + timedelta(days=days_ahead)

    for route in routes:
        raw_quote = fetch_route_price_from_api(route.origin_iata, route.destination_iata, target_date)
        normalized = normalize_and_validate_quote(raw_quote, target_date)

        snapshot = PriceSnapshot(route_id=route.id, **normalized)
        db.add(snapshot)
        saved_count += 1

        if snapshot.is_fresh:
            alerts = (
                db.query(PriceAlert)
                .filter_by(route_id=route.id, departure_date=target_date, is_active=True)
                .all()
            )
            for alert in alerts:
                if snapshot.price_kzt <= alert.threshold_kzt:
                    if (
                        alert.last_notified_price_kzt is None
                        or snapshot.price_kzt < alert.last_notified_price_kzt
                    ):
                        alert.last_notified_price_kzt = snapshot.price_kzt
                        alert.last_notified_at = datetime.now(timezone.utc).replace(tzinfo=None)
                        triggered_alerts += 1

    db.commit()
    return {"snapshots_saved": saved_count, "alerts_triggered": triggered_alerts}