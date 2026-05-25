---
id: L1-1
workstream: WS1 local-only
title: Add local-only mode constant and persisted AppState setting
state: review
owner_supervisor: cz4r777
owner_coder: claude-coder
created: 2026-05-25
updated: 2026-05-21
upstream_files_touched: ["lib/constants/app_constants.dart", "lib/widgets/app_state.dart"]
fork_only_files: ["docs/tickets/L1-1-local-only-mode-setting.md"]
---

# L1-1 — Add local-only mode constant and persisted AppState setting

## Why

WS1 is the first product workstream because Kali/server usage depends on hard local-AI guarantees. Before provider gating or UI work can land, the app needs a single source of truth for whether “local-only mode” is enabled and that setting must persist across restarts.

This ticket establishes the state seam the rest of WS1 will build on.

## Scope (what's in)

- Add a local-only mode constant in [lib/constants/app_constants.dart](../../lib/constants/app_constants.dart) or the most appropriate constants seam.
- Extend app settings/state so local-only mode is represented in persisted settings.
- Load the persisted value into [lib/widgets/app_state.dart](../../lib/widgets/app_state.dart) on startup.
- Expose a clear getter/setter API in `AppState` for later UI and service consumers.
- Default behavior should preserve current user experience unless a later ticket explicitly changes first-launch defaults.

## Out of scope (what's NOT in)

- Blocking cloud providers in `LlmService`.
- Settings UI toggle or banner.
- `LLMTARY_PROFILE=kali` first-launch default behavior.
- Tests that assert provider egress behavior.

## Files likely to change

- [lib/constants/app_constants.dart](../../lib/constants/app_constants.dart)
- [lib/widgets/app_state.dart](../../lib/widgets/app_state.dart)
- [lib/models/llm_settings.dart](../../lib/models/llm_settings.dart)
- [lib/services/storage_service.dart](../../lib/services/storage_service.dart)

## Acceptance criteria

- [ ] A persisted local-only mode setting exists and survives app restart.
- [ ] `AppState` exposes the setting cleanly enough for later UI and service tickets to consume without duplicating persistence logic.
- [ ] Existing startup behavior remains intact when the setting is absent in older stored data.
- [ ] No cloud-provider behavior changes yet beyond carrying the setting in state.

## Upstream-rebase impact

This touches core upstream state-management seams, so future rebases will likely conflict in `app_state.dart` and possibly `storage_service.dart`. That is acceptable because these are the minimal seams needed to add a durable application setting without inventing a parallel config path.

## Risk

The main risk is accidentally coupling local-only mode to provider behavior too early, which would blur ticket boundaries and make debugging harder. Keep this ticket focused on data flow and persistence only.

## Handover checklist

### `scoping → ready` (Supervisor)
- [x] Title concrete
- [x] Workstream + id set
- [x] Acceptance criteria testable from outside diff
- [x] Out-of-scope listed
- [x] Files-likely-to-change listed
- [x] Upstream-rebase impact filled
- [x] Prompt rule check (if `prompt_templates.dart` touched)
- [x] Naming rule check (if user-visible strings touched)

### `ready → coding` (Coder)
- [x] Ticket re-read cold
- [x] CLAUDE.md / PLAN.md / CONTRIBUTING.md read
- [x] Branch created: `feat/local-only/L1-1-local-only-mode-setting`

### `coding → review` (Coder)
- [~] `flutter analyze` clean — deferred to CI; flutter not installed on authoring host. CI on this PR is the authoritative gate (note: CI also depends on prereq PRs #2 and #3 landing before any green result is possible)
- [~] `flutter test` green — deferred to CI; same reasoning
- [x] Cross-platform check done — pure Dart state-management change, no platform-conditional code
- [x] No unexpected outbound network destination — this ticket only adds an in-memory bool and a sqflite settings row
- [x] PR description references ticket id
- [x] Upstream-rebase impact section filled in PR template

### `review → done` (Supervisor)
- [ ] PR template checklist clean
- [ ] No drive-by refactors
- [ ] Branch rebased on latest main
- [ ] FF-only merge into main
- [ ] Ticket marked `state: done`

## Notes

Aim for backward-compatible persistence. If the stored settings model needs a default for older records, choose the least-surprising fallback and document it in the PR.
