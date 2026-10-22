from datetime import date
import statistics
from sqlalchemy.orm import Session
from app.models import Route, PriceSnapshot
from app.schemas import RouteAnalyticsOut


def _calculate_linear_prediction(x_vals: list[float], y_vals: list[float], target_x: float) -> float:
    n = len(x_vals)
    if n < 2:
        return y_vals[-1]
    x_mean = statistics.mean(x_vals)
    y_mean = statistics.mean(y_vals)
    denominator = sum((x - x_mean) ** 2 for x in x_vals)
    if denominator == 0:
        return y_mean
    slope = sum((x - x_mean) * (y - y_mean) for x, y in zip(x_vals, y_vals)) / denominator
    intercept = y_mean - slope * x_mean
    return slope * target_x + intercept


def evaluate_route_price(db: Session, route_id: int, dep_date: date) -> RouteAnalyticsOut:
    route = db.query(Route).filter_by(id=route_id).first()
    snapshots = (
        db.query(PriceSnapshot)
        .filter_by(route_id=route_id, departure_date=dep_date, is_fresh=True)
        .order_by(PriceSnapshot.collected_at.asc())
        .all()
    )

    if not snapshots:
        return RouteAnalyticsOut(
            route_id=route.id,
            origin_iata=route.origin_iata,
            destination_iata=route.destination_iata,
            departure_date=dep_date,
            current_min_price_kzt=None,
            historical_median_kzt=None,
            expected_price_linear_kzt=None,
            price_assessment="INSUFFICIENT_DATA",
            total_observations=0,
        )

    prices = [float(s.price_kzt) for s in snapshots]
    current_price = prices[-1]
    median_price = float(statistics.median(prices))

    expected_linear = median_price
    if len(snapshots) >= 3:
        x_days = [float(s.days_before_departure) for s in snapshots[:-1]]
        y_prices = prices[:-1]
        target_days = float(snapshots[-1].days_before_departure)
        expected_linear = float(_calculate_linear_prediction(x_days, y_prices, target_days))

    if current_price <= median_price * 0.92:
        assessment = "LOW"
    elif current_price >= median_price * 1.08:
        assessment = "HIGH"
    else:
        assessment = "TYPICAL"

    return RouteAnalyticsOut(
        route_id=route.id,
        origin_iata=route.origin_iata,
        destination_iata=route.destination_iata,
        departure_date=dep_date,
        current_min_price_kzt=round(current_price, 2),
        historical_median_kzt=round(median_price, 2),
        expected_price_linear_kzt=round(expected_linear, 2),
        price_assessment=assessment,
        total_observations=len(snapshots),
    )