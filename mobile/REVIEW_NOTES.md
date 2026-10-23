# Review of the supplied Flutter prototype

Reviewed 23 October 2026 from the user-supplied `kz-flights-monitor.zip`. Only the mobile client was adapted; the ZIP and published backend were not overwritten.

## Findings in the original archive

- `Icons.ConnectingAirports` did not compile. The correct icon is `Icons.connecting_airports`.
- The archive lacked platform launch folders. A Web launcher was generated for this review. Android SDK was not found, so native Android was not built or tested.
- API failures silently turned into generated routes/history/prices. Demo analytics always named ALA→NQZ even for other route IDs.
- An alert request exception returned success, and the UI claimed a notification had been sent although no delivery adapter existed.
- There were six fallback routes while the navigation label claimed twelve.
- Route/detail loading had no error state or mounted checks; the text controller was not disposed.
- Favorites and threshold/deduplication maps were session memory, despite dependencies suggesting persistent storage.

## Adaptations in this copy

- Fixed the compilation error and generated a minimal Web launcher.
- Added an explicit default `DEMO_MODE=true` and a persistent visible synthetic-data banner. This mode makes no airfare/backend requests; API errors in API mode do not fall back to demo data.
- Added twelve candidate directions and matching route metadata. The demo departure is fixed at 2026-11-06, with five synthetic observations on 19–23 October.
- Removed the invented linear estimate, retained unknown carrier metadata and did not mark synthetic prices fresh. The prior-history median is 25,000 KZT for the four earlier fixture points.
- Alert success requires an actual successful response in API mode. No common fake device token is supplied. The UI distinguishes a local demo threshold from server saving and never claims push delivery.
- Added bounded request timeouts, failure feedback, mounted checks, controller disposal, finite-price validation and save-button disabling.
- Limited displayed history to the analytics departure date and sorted it by observation time. Added a textual observation list alongside the simple graph.
- Replaced the unsupported tenge glyph in this Web environment with KZT. Enabled Web semantics for assistive technologies.

## Verification and remaining limitations

Flutter 3.47.5 / Dart 3.13.4: static analysis and two tests were used. Web release build and browser checks are recorded in the README. No provider request, real quote, backend deployment, native mobile build or push delivery is established by these checks.

The fixture repeats the same artificial price series for each route; it is for interface review, not analysis or ML. The departure date is fixed and no date picker or individual-flight/fare inventory is implemented. Favorites and local thresholds are lost on restart. The old alert helper is only in-memory decision logic, not delivery infrastructure or persistent deduplication. Baggage, notifications and real source provenance still need implementation. Dependencies `fl_chart` and `shared_preferences` are present in the archive but not used by these screens.

The Web build reported an optional CupertinoIcons font warning; this did not prevent the checked Material screens from rendering. iOS and Android remain unverified. The existing backend has separately documented source-time and simulation defects; API mode is not a validated real-fare path.
