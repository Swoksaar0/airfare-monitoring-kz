from datetime import datetime, date
from sqlalchemy import (
    Column, Integer, String, Float, Boolean, DateTime, Date, ForeignKey, UniqueConstraint
)
from sqlalchemy.orm import relationship
from app.database import Base


class Route(Base):
    __tablename__ = "routes"

    id = Column(Integer, primary_key=True, index=True)
    origin_iata = Column(String(3), nullable=False, index=True)
    origin_city = Column(String(100), nullable=False)
    destination_iata = Column(String(3), nullable=False, index=True)
    destination_city = Column(String(100), nullable=False)
    is_active = Column(Boolean, default=True)

    snapshots = relationship("PriceSnapshot", back_populates="route", cascade="all, delete-orphan")
    alerts = relationship("PriceAlert", back_populates="route", cascade="all, delete-orphan")

    __table_args__ = (
        UniqueConstraint("origin_iata", "destination_iata", name="uq_route_origin_dest"),
    )


class PriceSnapshot(Base):
    __tablename__ = "price_snapshots"

    id = Column(Integer, primary_key=True, index=True)
    route_id = Column(Integer, ForeignKey("routes.id", ondelete="CASCADE"), nullable=False, index=True)
    departure_date = Column(Date, nullable=False, index=True)
    price_kzt = Column(Float, nullable=False)
    airline_code = Column(String(10), nullable=True)
    flight_number = Column(String(20), nullable=True)
    transfers = Column(Integer, default=0)

    source_found_at = Column(DateTime, nullable=False)
    collected_at = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)
    is_fresh = Column(Boolean, default=True, nullable=False)
    days_before_departure = Column(Integer, nullable=False)

    route = relationship("Route", back_populates="snapshots")


class PriceAlert(Base):
    __tablename__ = "price_alerts"

    id = Column(Integer, primary_key=True, index=True)
    device_token = Column(String(255), nullable=False, index=True)
    route_id = Column(Integer, ForeignKey("routes.id", ondelete="CASCADE"), nullable=False)
    departure_date = Column(Date, nullable=False)
    threshold_kzt = Column(Float, nullable=False)
    is_active = Column(Boolean, default=True)

    last_notified_price_kzt = Column(Float, nullable=True)
    last_notified_at = Column(DateTime, nullable=True)

    route = relationship("Route", back_populates="alerts")