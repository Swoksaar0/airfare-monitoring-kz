from datetime import date, timedelta
from typing import List
from fastapi import FastAPI, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.config import settings
from app.database import Base, engine, get_db
from app.models import Route, PriceSnapshot, PriceAlert
from app.schemas import (
    RouteOut,
    PriceSnapshotOut,
    RouteAnalyticsOut,
    AlertCreate,
    AlertOut,
)
from app.services.collector import seed_initial_routes, collect_prices_for_active_routes
from app.services.analytics import evaluate_route_price

Base.metadata.create_all(bind=engine)

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="Сервер мониторинга и анализа динамики минимальных цен на авиабилеты внутри РК",
)


@app.on_event("startup")
def on_startup():
    db = next(get_db())
    seed_initial_routes(db)


@app.get("/health", tags=["System"])
def health_check():
    return {"status": "ok", "version": settings.VERSION}


@app.get("/api/v1/routes", response_model=List[RouteOut], tags=["Routes"])
def list_routes(db: Session = Depends(get_db)):
    return db.query(Route).filter_by(is_active=True).all()


@app.post("/api/v1/collect", tags=["Collector"])
def trigger_price_collection(
    days_ahead: int = Query(7, ge=1, le=60),
    db: Session = Depends(get_db),
):
    result = collect_prices_for_active_routes(db, days_ahead=days_ahead)
    return {"status": "completed", **result}


@app.get(
    "/api/v1/routes/{route_id}/history",
    response_model=List[PriceSnapshotOut],
    tags=["Prices & Analytics"],
)
def get_route_price_history(
    route_id: int,
    only_fresh: bool = Query(True, description="Фильтровать устаревший кеш"),
    db: Session = Depends(get_db),
):
    route = db.query(Route).filter_by(id=route_id).first()
    if not route:
        raise HTTPException(status_code=404, detail="Route not found")

    query = db.query(PriceSnapshot).filter_by(route_id=route_id)
    if only_fresh:
        query = query.filter_by(is_fresh=True)
    return query.order_by(PriceSnapshot.collected_at.asc()).all()


@app.get(
    "/api/v1/routes/{route_id}/analytics",
    response_model=RouteAnalyticsOut,
    tags=["Prices & Analytics"],
)
def get_route_analytics(
    route_id: int,
    departure_date: date = Query(default_factory=lambda: date.today() + timedelta(days=7)),
    db: Session = Depends(get_db),
):
    route = db.query(Route).filter_by(id=route_id).first()
    if not route:
        raise HTTPException(status_code=404, detail="Route not found")
    return evaluate_route_price(db, route_id=route_id, dep_date=departure_date)


@app.post("/api/v1/alerts", response_model=AlertOut, tags=["Alerts"])
def create_price_alert(payload: AlertCreate, db: Session = Depends(get_db)):
    alert = PriceAlert(**payload.model_dump())
    db.add(alert)
    db.commit()
    db.refresh(alert)
    return alert