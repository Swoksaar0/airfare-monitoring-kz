"""Offline acceptance diagnostics. No live providers or production DB are used.

Run with --backend-root pointing at the backend directory of the declared commit.
The report distinguishes a completed diagnostic run from passed acceptance checks.
"""
import argparse
import ast
import hashlib
import importlib.metadata
import json
import math
import os
from pathlib import Path
import platform
import socket
import statistics
import sys
import tempfile
import time
from datetime import date, datetime, timedelta, timezone
from unittest.mock import patch


def run(backend_root, commit):
    sys.path.insert(0, str(backend_root))
    source_files = sorted(backend_root.rglob('*.py'))
    report = {
        'executed_at': datetime.now(timezone.utc).isoformat(),
        'source_commit': commit,
        'python': platform.python_version(),
        'platform': platform.platform(),
        'dependencies': {p: importlib.metadata.version(p) for p in
                         ['fastapi', 'sqlalchemy', 'httpx', 'pydantic', 'pydantic-settings']},
        'environment': 'Disposable SQLite with foreign keys; in-process ASGI; mocked provider HTTP',
        'source_sha256': {str(p.relative_to(backend_root)): hashlib.sha256(p.read_bytes()).hexdigest()
                          for p in source_files},
        'provider_requests': 0,
        'network_connection_attempts_blocked': 0,
        'checks': [],
    }

    original_connect = socket.socket.connect

    def block_connect(sock, address):
        # Windows asyncio creates its wake-up socket pair on loopback.
        if isinstance(address, tuple) and address[0] in ('127.0.0.1', '::1'):
            return original_connect(sock, address)
        report['network_connection_attempts_blocked'] += 1
        raise RuntimeError('External network disabled for offline verification')

    def record(identifier, name, condition, expected, actual):
        report['checks'].append(dict(id=identifier, name=name,
            status='PASS' if condition else 'FAIL', expected=expected, actual=actual))

    with tempfile.TemporaryDirectory(prefix='airfare-verification-') as tmp:
        os.environ['DATABASE_URL'] = 'sqlite:///' + (Path(tmp) / 'test.sqlite3').as_posix()
        os.environ['TRAVELPAYOUTS_TOKEN'] = ''
        # Work outside any tracked .env. Explicit environment values take priority.
        original_cwd = Path.cwd()
        os.chdir(tmp)
        try:
            with patch.object(socket.socket, 'connect', block_connect):
                import httpx
                from sqlalchemy import event
                from fastapi.testclient import TestClient
                from app.database import engine, SessionLocal
                @event.listens_for(engine, 'connect')
                def foreign_keys(connection, record):
                    connection.execute('PRAGMA foreign_keys=ON')
                from app.main import app
                from app.config import settings
                from app.models import Route, PriceSnapshot
                from app.services.collector import (seed_initial_routes, fetch_route_price_from_api,
                    normalize_and_validate_quote, collect_prices_for_active_routes)

                target = date.today() + timedelta(days=7)
                now = datetime.now(timezone.utc)
                with TestClient(app, raise_server_exceptions=False) as client:
                    routes = client.get('/api/v1/routes').json()
                    rid = routes[0]['id']
                    with SessionLocal() as db:
                        added = seed_initial_routes(db)
                        pairs = [(r.origin_iata, r.destination_iata) for r in db.query(Route).all()]
                    record('VT-01', 'Unique idempotent route seed',
                        len(routes) == 12 and added == 0 and len(set(pairs)) == 12
                        and ('ALA', 'NQZ') in pairs and ('NQZ', 'ALA') in pairs,
                        '12 unique directional routes; second seed adds zero',
                        dict(routes=len(routes), added_on_second_seed=added))
                    response = client.get('/health')
                    record('VT-13a', 'Health endpoint', response.status_code == 200,
                           'HTTP 200', response.status_code)
                    empty = client.get(f'/api/v1/routes/{rid}/analytics',
                        params={'departure_date': str(target)}).json()
                    record('VT-07a', 'Empty analytics', empty['price_assessment'] == 'INSUFFICIENT_DATA',
                           'INSUFFICIENT_DATA', empty['price_assessment'])
                    invalid_horizon = [client.post('/api/v1/collect', params={'days_ahead': n}).status_code
                                       for n in [-1, 0, 61]]
                    record('VT-02a', 'Collection horizon validation', invalid_horizon == [422] * 3,
                           'HTTP 422 for -1, 0, 61', invalid_horizon)

                    outcomes = {}
                    with patch.object(settings, 'TRAVELPAYOUTS_TOKEN', ''):
                        missing = fetch_route_price_from_api('ALA', 'NQZ', target)
                        outcomes['missing_token'] = {'price_returned': 'price' in missing,
                                                   'synthetic_label': missing.get('is_synthetic')}
                    with patch.object(settings, 'TRAVELPAYOUTS_TOKEN', 'offline-placeholder'):
                        for scenario in ['empty', 'timeout', 'http_error']:
                            with patch('app.services.collector.httpx.Client') as provider:
                                mock_client = provider.return_value.__enter__.return_value
                                if scenario == 'timeout':
                                    mock_client.get.side_effect = httpx.ReadTimeout('mock timeout')
                                elif scenario == 'http_error':
                                    mock_client.get.return_value.raise_for_status.side_effect = RuntimeError('mock HTTP 503')
                                else:
                                    mock_client.get.return_value.json.return_value = {'data': []}
                                result = fetch_route_price_from_api('ALA', 'NQZ', target)
                                outcomes[scenario] = {'price_returned': 'price' in result,
                                                      'synthetic_label': result.get('is_synthetic')}
                        with patch('app.services.collector.httpx.Client') as provider:
                            departure = target.isoformat() + 'T10:00:00+05:00'
                            provider.return_value.__enter__.return_value.get.return_value.json.return_value = {
                                'data': [{'price': 30000, 'airline': 'DV', 'flight_number': '703',
                                          'departure_at': departure}]}
                            mapped = fetch_route_price_from_api('ALA', 'NQZ', target)
                    record('VT-03', 'Missing and failed provider responses',
                        not any(v['price_returned'] for v in outcomes.values()),
                        'No market quote for missing token, empty response, timeout or HTTP error', outcomes)
                    record('VT-05a', 'Departure is not source observation time',
                        mapped.get('found_at') != departure,
                        'Unknown source observation time remains unknown',
                        {'found_at_equals_departure': mapped.get('found_at') == departure})
                    instant = now - timedelta(hours=50)
                    utc = normalize_and_validate_quote({'price': 30000, 'found_at': instant.isoformat()}, target)
                    offset = normalize_and_validate_quote({'price': 30000, 'found_at':
                        instant.astimezone(timezone(timedelta(hours=5))).isoformat()}, target)
                    record('VT-05b', 'Equivalent UTC and offset timestamps',
                        utc['source_found_at'] == offset['source_found_at'] and not offset['is_fresh'],
                        'Equal instants and both stale at age 50 h with 48 h limit',
                        dict(utc=str(utc['source_found_at']), offset=str(offset['source_found_at']),
                             offset_is_fresh=offset['is_fresh'], limit_hours=settings.CACHE_FRESHNESS_HOURS))
                    unknown = normalize_and_validate_quote({'price': 30000}, target)
                    future = normalize_and_validate_quote({'price': 30000, 'found_at':
                        (now + timedelta(days=1)).isoformat()}, target)
                    record('VT-05c', 'Unknown and future source metadata',
                        unknown['source_found_at'] is None and not future['is_fresh'],
                        'Unknown time retained; future source time invalid',
                        dict(unknown_time_invented=unknown['source_found_at'] is not None,
                             unknown_airline=unknown['airline_code'], future_is_fresh=future['is_fresh']))
                    with patch.object(settings, 'TRAVELPAYOUTS_TOKEN', ''):
                        unauthorized = client.post('/api/v1/collect', params={'days_ahead': 7})
                    record('VT-11', 'Operator authorization', unauthorized.status_code in [401, 403],
                        '401/403 before collection', dict(status=unauthorized.status_code,
                        snapshots_saved=unauthorized.json().get('snapshots_saved')))
                    alert = {'device_token': 'offline-test-only', 'route_id': rid,
                             'departure_date': str(target), 'threshold_kzt': 30000}
                    codes = {key: client.post('/api/v1/alerts', json={**alert, **changes}).status_code
                             for key, changes in [('valid', {}), ('negative', {'threshold_kzt': -1}),
                                                   ('missing_route', {'route_id': 999999}),
                                                   ('past_date', {'departure_date': str(date.today()-timedelta(days=1))})]}
                    record('VT-08', 'Alert input validation', codes['valid'] == 200 and codes['negative'] == 422
                        and codes['missing_route'] in [400, 404, 422] and codes['past_date'] in [400, 422],
                        'Valid accepted; negative/past rejected; missing route is client error', codes)
                    with SessionLocal() as db:
                        db.query(PriceSnapshot).delete()
                        for route in db.query(Route).all():
                            route.is_active = route.id == rid
                        db.commit()
                        fixed = {'price': 25000, 'airline': 'DV', 'flight_number': '703', 'found_at': now.isoformat()}
                        with patch('app.services.collector.fetch_route_price_from_api', return_value=fixed):
                            first = collect_prices_for_active_routes(db, 7)
                            second = collect_prices_for_active_routes(db, 7)
                        count = db.query(PriceSnapshot).count()
                        record('VT-06', 'Replayed source observation', count == 1,
                               '1 independent quote after replay', {'stored_rows': count})
                        record('VT-09a', 'Repeated threshold state update suppression',
                            first['alerts_triggered'] == 1 and second['alerts_triggered'] == 0,
                            'First run 1 state update, replay 0; delivery is not tested',
                            dict(first=first['alerts_triggered'], replay=second['alerts_triggered']))
                        db.add(PriceSnapshot(route_id=rid, departure_date=target+timedelta(days=1),
                            price_kzt=40000, source_found_at=now.replace(tzinfo=None),
                            collected_at=now.replace(tzinfo=None), is_fresh=True, days_before_departure=8))
                        db.commit()
                    hist = client.get(f'/api/v1/routes/{rid}/history', params={'departure_date': str(target)}).json()
                    dates = sorted({row['departure_date'] for row in hist})
                    record('VT-04', 'History departure-date isolation', dates == [str(target)],
                           'Only requested departure date', dates)
                    with SessionLocal() as db:
                        db.query(PriceSnapshot).delete()
                        for i, amount in enumerate([10000, 20000]):
                            db.add(PriceSnapshot(route_id=rid, departure_date=target, price_kzt=amount,
                                source_found_at=now.replace(tzinfo=None), collected_at=now.replace(tzinfo=None)+timedelta(seconds=i),
                                is_fresh=True, days_before_departure=7-i))
                        db.commit()
                    value = client.get(f'/api/v1/routes/{rid}/analytics', params={'departure_date': str(target)}).json()
                    record('VT-07b', 'Prior median excludes current', value['historical_median_kzt'] == 10000,
                           'Prior median 10000 for [10000, current 20000]', value['historical_median_kzt'])
                    accepted = []
                    for amount in [-1, float('nan'), float('inf')]:
                        try:
                            normalize_and_validate_quote({'price': amount, 'found_at': now.isoformat()}, target)
                            accepted.append(str(amount))
                        except (ValueError, OverflowError):
                            pass
                    record('VT-12a', 'Reject invalid quote money', not accepted,
                           'Negative, NaN and infinity rejected before persistence', {'accepted': accepted})
                    with SessionLocal() as db:
                        db.query(PriceSnapshot).delete()
                        db.add_all([PriceSnapshot(route_id=rid, departure_date=target, price_kzt=30000+i%100,
                            source_found_at=now.replace(tzinfo=None), collected_at=now.replace(tzinfo=None)+timedelta(seconds=i),
                            is_fresh=True, days_before_departure=7) for i in range(1000)])
                        db.commit()
                    timings = []
                    for i in range(33):
                        started = time.perf_counter()
                        result = client.get(f'/api/v1/routes/{rid}/history')
                        elapsed = (time.perf_counter()-started)*1000
                        assert result.status_code == 200 and len(result.json()) == 1000
                        if i >= 3:
                            timings.append(elapsed)
                    p95 = sorted(timings)[math.ceil(.95*len(timings))-1]
                    record('VT-14-local', 'Local history latency characterization', p95 <= 2000,
                        'Provisional p95 <=2000 ms; SQLite/ASGI only, not production acceptance',
                        dict(samples=30, warmup=3, rows=1000, concurrent_clients=1,
                             p95_ms=round(p95, 2), median_ms=round(statistics.median(timings), 2)))
                engine.dispose()
        finally:
            os.chdir(original_cwd)
    for source in source_files:
        ast.parse(source.read_text(encoding='utf-8-sig'))
    report['syntax_files_passed'] = len(source_files)
    report['summary'] = {status: sum(c['status'] == status for c in report['checks']) for status in ['PASS', 'FAIL']}
    return report


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--backend-root', type=Path, required=True)
    parser.add_argument('--source-commit', required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    result = run(args.backend_root.resolve(), args.source_commit)
    args.output.write_text(json.dumps(result, indent=2, ensure_ascii=False, allow_nan=False), encoding='utf-8')
    print(json.dumps({'summary': result['summary'], 'checks': result['checks'], 'output': str(args.output)}, indent=2))
