# Existing airfare systems: evidence-based comparison

**Status:** research draft, 23 October 2026; peer/user/supervisor review pending.  
**Related issue:** [#3](https://github.com/Swoksaar0/airfare-monitoring-kz/issues/3).

## Method and limits

Compare three relevant consumer services using the same eight criteria: Google Flights, Aviasales and Skyscanner. These were selected because they provide flight discovery and price tracking, which overlap with our intended scenarios. The final column describes the current Flutter demo, not the promised final application.

Evidence is official product/help documentation reviewed on the date above. This is a document-based comparison, not a hands-on market-coverage or performance benchmark. **Not established** means that the reviewed sources do not establish the capability; it does not mean the product lacks it. No numerical score or claim of superiority is assigned.

A calendar/graph comparing different **departure dates** is not proof of a chronological history of repeated observations for **one departure date**. Likewise, a saved flight is not evidence of a user-configurable numeric alert threshold.

## Common comparison matrix

| Criterion | Google Flights | Aviasales | Skyscanner | Current Flutter demo |
| --- | --- | --- | --- | --- |
| C1. Search by direction and departure date | Documented route/date and one-way search [G1] | Route, dates, passengers and cabin selection [A1] | Route/date search is part of the documented alert workflow [S1] | 12 candidate directions; fixed demo departure 2026-11-06; date picker pending |
| C2. Compare prices across different departure dates | Date grid and price graph [G1] | Price calendar and flexible dates [A1] | Monthly calendar/grid of indicative prices [S2] | Not implemented |
| C3. Receive price-change notifications | Email updates for tracked routes/flights; searched dates or flexible dates [G2] | Favorite a ticket to receive price-change notifications [A1] | Route/date alerts via account and email [S1] | Session-local threshold only; no delivered push |
| C4. Save/manage tracked options | Tracked Flights supports viewing, toggling email and removing tracking [G2] | Saving a ticket in Favorites is documented [A1]; management details not evaluated | Alerts can be removed through profile/email [S1] | Session favorites and a local threshold; restart persistence pending |
| C5. History of a fixed departure date over observation time | Partial: historical insights are documented for some routes [G3]; a complete raw observation series is not established | A fixed-departure longitudinal-history display is not established by [A1]; its calendar serves C2 | A fixed-departure longitudinal-history display is not established by [S1] / [S2]; its monthly grid serves C2 | Five synthetic observation dates for one fixed departure; no real history yet |
| C6. Baggage context for comparison | Bag-fee filter uses partner baggage information [G4] | Results include baggage information and a baggage filter [A1] | Allowances/fees depend on provider and fare; confirm what is included [S3]; equivalent result-filter coverage not established | No baggage UI/data in this Flutter version; do not infer allowances |
| C7. Price freshness/availability limitations | Partner inventory is incomplete; booking price discrepancies can occur [G1]. No collection-time SLA was tested | Freshness interval and observation timestamp behavior not established by the reviewed guide [A1] | Calendar prices are indicative [S2]; alerts are a snapshot and can differ from later availability [S4] | Explicit synthetic-data banner; source freshness not demonstrated |
| C8. Documented user interface channels | Browser workflow, including mobile browser instructions [G1] | Website and mobile application [A1] | Desktop/mobile website and mobile app workflows [S1] / [S2] | Flutter Web checked; Android/iOS not built |

[S1] / [S2] above means the combined reviewed Skyscanner alert and search guides, not an additional source.

## Interpretation for this diploma

**Established overlap:** price alerts, saved options and flexible-date tools already exist. A defensible proposal must not describe these as unique inventions.

**Different research focus:** our intended contribution is a bounded, reproducible monitoring pipeline for selected domestic Kazakhstan directions: retain source provenance, collection/source times, missing outcomes and fixed-departure histories; then evaluate a documented statistical baseline. These are project aims, not evidence that other services cannot do them.

**Prototype gap:** our demo is substantially narrower than the existing services. Its synthetic graph proves a screen interaction, not actual market coverage, useful forecasting or reliable notifications. A numeric threshold is shown locally; backend persistence and delivery still require verification.

**Design implications:**

- FR-02 needs an actual departure-date selector; changing the departure date must change the group being analyzed.
- FR-04/05 must distinguish observation time, departure time and indicative/cached/live status.
- FR-07/08 need explicit rule management and actual delivery evidence; do not claim that a boolean threshold check sends a notification.
- Baggage should remain unknown until a source supplies its unit, quantity, weight and applicability.
- User discussions must establish whether these explanations help the target users; product documentation cannot substitute for interviews.

## Kazakhstan coverage follow-up — not performed

For a later bounded pilot, use the same passenger/currency/one-way conditions and agreed future departure dates on ALA→NQZ, NQZ→ALA and ALA→CIT. Record the actual observation time, carrier, itinerary, baggage terms, availability and redirect/final-price differences where available. Respect each source's access conditions. Do not translate a missing search result into “no flight exists.”

No searches, bookings, accounts, alert subscriptions or provider API calls were made for this document. Carrier inventory, app usability and performance have not been tested.

## Official sources

All accessed/reviewed 23 October 2026. These are product references, not scientific publications or the required literature-review dataset.

- [G1 — Google: find plane tickets, search/date tools and coverage limitations](https://support.google.com/travel/answer/2475306?hl=en-EN).
- [G2 — Google: track flights and prices, manage tracking](https://support.google.com/travel/answer/6235879?hl=en).
- [G3 — Google: historical insights are available on some routes](https://www.google.com/travel/flights/g).
- [G4 — Google: filter flight prices by bag fees](https://support.google.com/travel/answer/9074247?hl=en).
- [A1 — Aviasales: how the website and application work](https://www.aviasales.ru/faq/kak-najti-i-kupit-samye-deshevye-aviabilety).
- [S1 — Skyscanner: set up/cancel email price alerts](https://help.skyscanner.net/hc/en-us/articles/115002499829-How-do-I-set-up-or-cancel-email-price-alerts).
- [S2 — Skyscanner: monthly search and indicative-price explanation](https://help.skyscanner.net/hc/en-us/sections/200406602-How-do-I-search-for).
- [S3 — Skyscanner: baggage information before booking](https://help.skyscanner.net/hc/en-us/sections/200407752-Before-you-Book).
- [S4 — Skyscanner: price/alert snapshot limitations](https://help.skyscanner.net/hc/en-gb/categories/200368471-Prices).

[G1]: https://support.google.com/travel/answer/2475306?hl=en-EN
[G2]: https://support.google.com/travel/answer/6235879?hl=en
[G3]: https://www.google.com/travel/flights/g
[G4]: https://support.google.com/travel/answer/9074247?hl=en
[A1]: https://www.aviasales.ru/faq/kak-najti-i-kupit-samye-deshevye-aviabilety
[S1]: https://help.skyscanner.net/hc/en-us/articles/115002499829-How-do-I-set-up-or-cancel-email-price-alerts
[S2]: https://help.skyscanner.net/hc/en-us/sections/200406602-How-do-I-search-for
[S3]: https://help.skyscanner.net/hc/en-us/sections/200407752-Before-you-Book
[S4]: https://help.skyscanner.net/hc/en-gb/categories/200368471-Prices
