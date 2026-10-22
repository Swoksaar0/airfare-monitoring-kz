from datetime import date, datetime
from typing import Optional, List
from pydantic import BaseModel, Field


class RouteOut(BaseModel):
    id: int
    origin_iata: str
    origin_city: str
    destination_iata: str
    destination_city: str
    is_active: bool

    class Config:
        from_attributes = True


class PriceSnapshotOut(BaseModel):
    id: int
    route_id: int
    departure_date: date
    price_kzt: float
    airline_code: Optional[str]
    transfers: int
    source_found_at: datetime
    collected_at: datetime
    is_fresh: bool
    days_before_departure: int

    class Config:
        from_attributes = True


class RouteAnalyticsOut(BaseModel):
    route_id: int
    origin_iata: str
    destination_iata: str
    departure_date: date
    current_min_price_kzt: Optional[float]
    historical_median_kzt: Optional[float]
    expected_price_linear_kzt: Optional[float]
    price_assessment: str
    total_observations: int


class AlertCreate(BaseModel):
    device_token: str = Field(..., description="FCM-токен мобильного устройства")
    route_id: int
    departure_date: date
    threshold_kzt: float = Field(..., gt=0, description="Порог цены в тенге")


class AlertOut(BaseModel):
    id: int
    route_id: int
    departure_date: date
    threshold_kzt: float
    is_active: bool
    last_notified_price_kzt: Optional[float]
    last_notified_at: Optional[datetime]

    class Config:
        from_attributes = True