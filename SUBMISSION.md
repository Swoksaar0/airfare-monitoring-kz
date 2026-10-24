# Probationary period 1 submission

**Tag:** `prob-period-1`. **Date:** 24 October 2026.
**Project:** Development of a Mobile Application for Monitoring and Analyzing Airfare Dynamics on Domestic Routes in Kazakhstan.

This tag packages the matching backend, Flutter prototype, documentation and checked Word report in one immutable checkpoint version. Use the tag link in the submission form rather than a development branch.

## Submission links

- [Exact project version](https://github.com/Swoksaar0/airfare-monitoring-kz/tree/prob-period-1)
- [Word report](https://github.com/Swoksaar0/airfare-monitoring-kz/blob/prob-period-1/submission/Airfare_Monitoring_KZ_Probationary_Period_1.docx)
- [Documentation index](https://github.com/Swoksaar0/airfare-monitoring-kz/blob/prob-period-1/docs/README.md)
- [Flutter source and launch instructions](https://github.com/Swoksaar0/airfare-monitoring-kz/blob/prob-period-1/mobile/README.md)
- [Verification outcomes](https://github.com/Swoksaar0/airfare-monitoring-kz/blob/prob-period-1/docs/VERIFICATION_RESULTS.md)
- [Management and risks](https://github.com/Swoksaar0/airfare-monitoring-kz/blob/prob-period-1/docs/PROJECT_PLAN.md)
- [Source manifest](https://github.com/Swoksaar0/airfare-monitoring-kz/blob/prob-period-1/submission/manifest.json)

## Included materials

`backend/` contains the existing FastAPI, collector, analytics and ORM baseline. `mobile/` contains the tested Flutter prototype, three test files and two screenshots. `docs/` contains the proposal, requirements, research, comparisons, editable diagram sources and exports, verification evidence, project plan and feedback templates. `submission/` contains the unchanged 48-page Word report and a manifest identifying its source revisions and SHA-256.

The report describes these component revisions; it was rendered and checked before packaging. It is included byte-for-byte, without new content or invented approval. Its branch links locate the source workspaces; the immutable sources are identified by the commit IDs below and by this tag. A separate report file uploaded to a form should be this exact file, not an older copy.

## Source provenance

| Component | Source commit |
| --- | --- |
| Backend baseline | [4c16b32647e9](https://github.com/Swoksaar0/airfare-monitoring-kz/commit/4c16b32647e9dc780eec368a4ce20f015986c539) |
| Flutter prototype | [d14b0d8ae006](https://github.com/Swoksaar0/airfare-monitoring-kz/commit/d14b0d8ae006b84e34b33470ba1b168849222057) |
| Documentation | [ce8977e2afe1](https://github.com/Swoksaar0/airfare-monitoring-kz/commit/ce8977e2afe1e7009047e4b19c04d2840d74b672) |

The backend and executable mobile files are unchanged. Packaging changes are limited to submission navigation, launch instructions, the manifest and inclusion of the checked report. The separate development branches and main are preserved.

## Reproduce this version

```sh
git clone --branch prob-period-1 https://github.com/Swoksaar0/airfare-monitoring-kz.git
cd airfare-monitoring-kz/mobile
flutter pub get
flutter --no-version-check run -d web-server --web-hostname=127.0.0.1 --web-port=8767 --dart-define=DEMO_MODE=true
```

The tag checkout is detached. The demo needs no provider credentials or database. See mobile/README.md for the previously checked Flutter/Dart versions and verification commands.

## Verification and limitations

The included evidence records 17 passing Flutter tests, clean static analysis and a successful Web build. Offline backend diagnostics record 6 passed and 10 failed conditions. These results belong to the source revisions above; packaging introduces no runtime-code changes and does not claim a fresh test run. No external provider requests were made during those checks.

The UI uses labelled synthetic prices and device-local rules. Source integrity, history/identity and authorization/validation repairs remain in issues #20–#22. Native builds, PostgreSQL deployment, live coverage, actual push delivery and prediction accuracy remain unverified. Human discussions, student peer review and supervisor feedback are not established by creating this tag.

`prob-period-1` is the requested submission tag. Earlier planning references to a future `pre-defense-1` tag are superseded for this checkpoint. Do not move or overwrite `prob-period-1`; later changes require a new version.

Report SHA-256: `d3c84e9a002e2698552e4ea50b476c5a2578c15dac525e7cbeec33cd248bb627`.
