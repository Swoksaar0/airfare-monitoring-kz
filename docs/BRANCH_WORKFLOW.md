# Branch organization and ownership

Prepared 23 October 2026. This separates review scopes; it does not split the application into unrelated repositories.

| Branch | Changes owned here | Responsible student | Review |
| --- | --- | --- | --- |
| [main](https://github.com/Swoksaar0/airfare-monitoring-kz/tree/main) | Shared accepted integration state | Both | Merge reviewed PRs; no checkpoint acceptance is implied by a merge |
| [backend](https://github.com/Swoksaar0/airfare-monitoring-kz/tree/backend) | `backend/`: server, collectors, database, analytics and backend checks | @Bekbauly | Open a PR to main after substantive changes exist |
| [mobile-app](https://github.com/Swoksaar0/airfare-monitoring-kz/tree/mobile-app) | `mobile/`: Flutter source, client tests, Web launcher, client README/review notes | @Swoksaar0 | [Mobile PR #19](https://github.com/Swoksaar0/airfare-monitoring-kz/pull/19) |
| [pre-defense-documents](https://github.com/Swoksaar0/airfare-monitoring-kz/tree/pre-defense-documents) | `docs/` and root README: proposal, requirements, research, diagrams, evaluation and checkpoint evidence | Both | [Documentation PR #18](https://github.com/Swoksaar0/airfare-monitoring-kz/pull/18) |

## How to use the branches

After saving/committing or stashing any local work, fetch branch names:

```sh
git fetch origin
git branch -r
```

Bekbauly switches to `backend`; Dinmukhammed switches to `mobile-app`; checkpoint edits go to `pre-defense-documents`. For a branch not yet checked out locally:

```sh
git switch --track origin/backend
# Or, for the mobile client:
git switch --track origin/mobile-app
# Or, for checkpoint documents:
git switch --track origin/pre-defense-documents
```

Run only the command for the branch you need. If the local branch already exists, use `git switch backend`, `git switch mobile-app`, or `git switch pre-defense-documents`.

A branch is a complete project snapshot. The current common baseline already contains `backend/`, so that folder is also visible in mobile/documentation branches. Do not delete shared folders merely to make a branch look exclusive: deletions are changes that can be proposed for integration. The **PR diff** identifies the work being reviewed.

## Scope and integration

- The mobile PR adds only `mobile/` relative to its main baseline. The client source is preserved from the reviewed prototype; only its README is clarified for the branch split.
- PR #18 changes documentation and the root README relative to main. Its earlier combined commits remain in history, while the final diff excludes Flutter files.
- The backend branch starts at the existing main commit. Creating it neither fixes collector defects nor creates a meaningful PR; Bekbauly opens that PR after implementing and checking his changes.
- Main is unchanged by the branch split. Mobile and documentation changes are still draft work awaiting review.
- The optional HTML sketch remains under `docs/prototype/` as a checkpoint reference. Flutter is the application framework.
- Cross-branch links deliberately point to `mobile-app` for client instructions. Keep that branch until those links are updated after integration.

For each change, reference its issue, document the checks, and ask the other student to review. Merge accepted PRs into main, then update the remaining work branches from main with normal merges after checking local changes. Resolve shared-file conflicts explicitly; do not force-push over a teammate's work.

The final `pre-defense-1` tag belongs on the agreed integrated revision after student/supervisor review. No such tag or final acceptance is created by this reorganization.
