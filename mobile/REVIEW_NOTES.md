# Flutter prototype review and completion notes

Updated 24 October 2026. The source started from the user-supplied archive and the reviewed GitHub client at `dd45060a`. Work in this revision affects the Flutter client only.

## Corrections retained from the first review

The earlier archive had a non-compiling icon, missing platform launchers, silent generated-price fallback on API failures, incorrect direction metadata, false notification-success messaging and incomplete request lifecycle handling. The first review introduced a Web launcher and explicit demo/API separation.

## Changes in version 0.2.0

- Added a Russian future-date picker and shortcuts; the selected date propagates to details and is restored after restart.
- Replaced session-only favorites and alert maps with a single serialized preference model. Writes are queued, and memory state is published only after a successful store write.
- Keyed local rules by directional airport pair and departure date. Amounts are stored as integer hundredths of KZT; input is validated before conversion.
- Added a dedicated tracking tab with persisted edit, activation/deactivation and removal.
- Kept demo and API preference scopes separate. There is no server-alert creation or device registration in this revision.
- Added independently selectable empty, failed, stale and single-observation demo states. Reload generations prevent an older in-flight response from replacing a newer date's result.
- Added source/collection-time labels, unknown metadata, future-source-time detection and a 48-hour age warning for the displayed observations.
- Changed descriptive analysis to exclude the current observation from the historical median. No linear forecast is generated for the demonstration.
- Chart x positions use actual observation instants, not equally spaced list indexes. Exact values and interactive point selection are provided in the text list.
- API history requests carry the selected date; local filtering preserves route/date grouping while the server contract is incomplete.
- Removed unused `fl_chart` and the old session-only alert/favorite helper files. Added localization and adaptive icon assets.

## Verification boundaries

Seventeen deterministic tests passed on Flutter 3.47.5 / Dart 3.13.4. Static analysis was clean and the release Web build succeeded. HTTP tests use a mock client; the demo test checks that no HTTP request occurs.

Browser checks at 390 × 844 exercised real preference restoration after a page reload, date selection, favorites, graph inspection, threshold saving/deactivation, and no-data/error presentation. Widget tests also exercise a 1.6 text scale. Browser screenshots are demonstration evidence, not interviews, native-device results or a usability study.

## Remaining work

- Fix backend simulation fallback, provenance, time semantics, exact money and server-side route/departure filtering before trusting API-mode data.
- Define a stable provider offer identity and comparable fare group; do not claim complete flight, tariff or baggage coverage.
- Add server-side rule management, authentication/device registration, scheduling, delivery attempts and durable notification deduplication.
- Generate/review native platform launchers, configure Android/iOS toolchains and test on real devices.
- Perform user discussions, supervisor review and an assistive-technology audit. No measured forecasting accuracy is claimed.

The default demo is sufficient to walk through the selected checkpoint scenarios. It does not finish live collection or production notifications.


