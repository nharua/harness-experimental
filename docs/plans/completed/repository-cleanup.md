# Execution Plan: Repository Cleanup

Date: 2026-07-22

## Status

Completed

## Outcome

Make the repository's current product, compatibility surface, historical
evidence, and validation suites immediately distinguishable without changing
the published core or compatibility behavior.

## Context

- `docs/WORKFLOW.md` makes current repository truth authoritative and reserves
  durable plans for coordinated, dependency-sensitive work.
- Decisions `0019` through `0024` separate the repository-centered core from
  the preserved SQLite and protocol-v1 compatibility surface.
- Root `PHASE*.md` files, top-level compatibility documents, completed plans,
  and migration-era tests currently overlap and obscure that separation.
- `scripts/harness-cli-install-files.txt` publishes several existing document
  paths. Moving those paths is a compatibility change and is not part of this
  first cleanup slice.

## Scope

In scope:

- Consolidate the active application-legibility phase into the active-plan
  index.
- Remove redundant completed phase summaries from the repository root when
  decisions and completed plans retain the lasting result.
- Update current indexes and documentation assertions to use the consolidated
  authority.
- Add one behavior-oriented test inventory that explains current, optional
  compatibility, and historical/migration suites.
- Delete migration-era executables after verifying they have no current
  pre-merge, release-workflow, installed-payload, or protocol obligation.

Out of scope:

- Moving files listed in `scripts/harness-cli-install-files.txt`.
- Removing protocol v1, SQLite schemas, `harness-cli`, or its required tests.
- Reorganizing release workflows or changing installer behavior.
- Deleting any historical test that still has a current caller or retained
  executable proof obligation.

## Approach

1. Inventory root documents, compatibility payload paths, test groups, and
   validation callers.
2. Move the active Phase 3 evidence matrix into `docs/plans/active/` and update
   current references.
3. Remove root Phase 2, Phase 4, and Phase 5 summaries after retaining current
   authority in decisions, compatibility references, and completed plans.
4. Replace documentation tests that require duplicated phase files with checks
   against the surviving plan and decision records.
5. Add `tests/README.md` describing what each suite protects, who observes a
   failure, how it is invoked, and its removal boundary.
6. Trace migration-era scripts through current validation and release callers;
   remove only the caller-free E11 and cutover executables.
7. Run focused documentation, workflow, and boundary checks followed by the
   repository validation contract.

## Risks And Recovery

- Risk: a removed phase summary contains current authority not retained
  elsewhere. Mitigation: update current indexes first and validate required
  claims against decisions and completed plans.
- Risk: historical evidence contains literal references to old root paths.
  Mitigation: preserve historical prose and generated evidence as historical;
  update only references that claim to locate current authority.
- Risk: moving compatibility documents breaks installed CLI users. Mitigation:
  leave every published compatibility payload path unchanged in this slice.
- Recovery: restore removed or moved files from the preceding Git revision and
  revert the associated reference changes as one group.

## Progress

- [x] Inventory root documentation, test groups, compatibility manifests, and
  direct validation callers.
- [x] Consolidate phase documents and current references.
- [x] Add the test-suite ownership inventory.
- [x] Remove caller-free E11 and cutover verification executables.
- [x] Run focused validation.
- [x] Run the pre-merge repository contract.

## Decisions

- 2026-07-22: Preserve published compatibility paths during the first cleanup
  slice because decision `0022` requires a versioned migration before changing
  that contract.
- 2026-07-22: Use Git history rather than duplicate root phase summaries for
  completed Phase 2, Phase 4, and Phase 5 evolution.
- 2026-07-22: Treat active Phase 3 as durable coordinated work and place its
  evolving evidence matrix in `docs/plans/active/`.
- 2026-07-22: Remove one-time E11 and cutover executables after confirming that
  current pre-merge and release workflows do not invoke them. Preserve their
  reports and frozen evidence as history rather than executable product gates.

## Validation

- Focused proof: `tests/docs/test-doc-contracts.sh`,
  `tests/installer/assert-agent-authority-contract.sh`,
  `tests/boundary/test-phase5-optional-consumer-split.sh`, and
  `tests/workflow/test-repository-workflow.sh` passed.
- Link proof: a repository-wide local Markdown-link scan reported zero broken
  local links.
- Repository-required checks: `scripts/validate-premerge.sh` passed in a fresh
  temporary clone after bootstrapping tracked state, matching CI.
- Local limitation: the first run in the working checkout stopped at
  `verify-materialized-core-parity.sh` because its pre-existing ignored
  `harness.db` differs from tracked replay in `intake`. The database was not
  modified; fresh-state validation passed the same check.

## Result

Completed. Current application-legibility work now lives under the active-plan
index; completed Phase 2, Phase 4, and Phase 5 root summaries no longer duplicate
decisions and completed plans. The test-suite map separates current core,
optional compatibility, and removed historical proof. Thirty-four caller-free
E11/cutover scripts and tests were removed. Overall, the proposed tree has 35
fewer tracked files and approximately 3,928 fewer lines after accounting for
the three new consolidated documents. Published compatibility payload paths and
behavior remain unchanged.
