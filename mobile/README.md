# Flutter prototype — Airfare Monitoring KZ

The primary application prototype is **Flutter/Dart**, adapted from the supplied `kz-flights-monitor.zip`. The [browser HTML sketch](https://github.com/Swoksaar0/airfare-monitoring-kz/tree/pre-defense-documents/docs/prototype) is an earlier visual reference maintained with checkpoint documents.

## Branch and ownership

This client is maintained in `mobile-app` by @Swoksaar0. Its PR adds only `mobile/` to the shared main baseline. Backend work belongs in `backend`; checkpoint documents are in [pre-defense-documents](https://github.com/Swoksaar0/airfare-monitoring-kz/tree/pre-defense-documents/docs). Shared backend files remain visible here because Git branches retain the common project baseline.

From a clean checkout, fetch and switch to the client branch before using the commands below:

```sh
git fetch origin
git switch mobile-app
```

## Run the demo

Requires a Flutter SDK. Reviewed with Flutter 3.47.5 / Dart 3.13.4.

```sh
cd mobile
flutter pub get
flutter run -d web-server --web-hostname=127.0.0.1 --web-port=8766 --dart-define=DEMO_MODE=true
```

Open [the Flutter preview](http://127.0.0.1:8766/). Stop with Ctrl+C. If the SDK pauses on a background update check, add `--no-version-check` immediately after `flutter`.

The Web target is Flutter compiled from Dart. It is not the hand-written HTML/JavaScript sketch. Native Android/iOS behavior has not been verified. The archive did not contain platform wrappers; this copy includes a generated Web launcher. To add Android after installing/configuring its SDK, run `flutter create --platforms=android --project-name=kz_flights_mobile .` and select a connected device with `flutter devices`.

## Available scenarios

- Twelve candidate domestic directional routes; refresh and session-local favorites.
- Route details with one fixed demo departure date (2026-11-06), synthetic price history, an observation list and descriptive assessment.
- Finite positive threshold validation and a session-local demo threshold.
- Explicit synthetic-data banner, loading, no-history and error presentation.
- A simple CustomPainter chart; the route/date filtering keeps one departure date in view.

All directions reuse an artificial price series. No source coverage is implied. There is no date picker, individual-flight inventory, baggage comparison, real push delivery, or durable mobile storage yet. Restarting loses favorites and local thresholds.

## Modes and data quality

`DEMO_MODE` defaults to `true`. In this mode the client makes no backend/airfare requests and never claims a delivered notification. The demo data stay in client memory and are not sent to the backend.

An experimental API mode exists with `--dart-define=DEMO_MODE=false --dart-define=API_BASE_URL=http://127.0.0.1:8000`. This mode exposes failures instead of substituting generated prices. Its backend integration, browser CORS, device setup, source validity and notification delivery have **not** been validated; it is not the checkpoint demonstration path. Android emulator networking would require a different backend address. Do not use API mode as evidence that current prices are real.

## Checks

```sh
flutter analyze --no-pub
flutter test --no-pub
flutter build web --release --no-pub --no-web-resources-cdn --no-wasm-dry-run --dart-define=DEMO_MODE=true
```

On 23 October 2026 the adapted source passed static analysis and two tests: matching route/date metadata in demo mode, and the route → details → threshold flow including rejection of zero and honest success messaging. The release Web build succeeded. It reported an optional CupertinoIcons font warning; Android/iOS were not built.

See [REVIEW_NOTES.md](REVIEW_NOTES.md) for original defects, adaptations, test boundaries and remaining work. Peer/user/supervisor review is still pending; do not mark the full mobile application complete.
