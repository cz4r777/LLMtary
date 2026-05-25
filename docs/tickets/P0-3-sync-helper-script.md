---
id: P0-3
workstream: WS0 scaffold
title: Add upstream sync helper script for fork maintenance
state: coding
owner_supervisor: cz4r777
owner_coder: claude-coder
created: 2026-05-25
updated: 2026-05-21
upstream_files_touched: []
fork_only_files: ["scripts/sync-upstream.sh", "docs/tickets/P0-3-sync-helper-script.md", "CONTRIBUTING.md"]
---

# P0-3 — Add upstream sync helper script for fork maintenance

## Why

The fork already documents the upstream sync ritual in [PLAN.md](../../PLAN.md) and [CONTRIBUTING.md](../../CONTRIBUTING.md), but the process is still manual. That increases the chance of drift, skipped steps, or accidental deviation from the fast-forward-only rule on `main`.

This ticket turns the documented ritual into a repeatable helper script so the Supervisor can keep the fork synced with upstream using one well-defined entrypoint.

## Scope (what's in)

- Add a POSIX shell helper at [scripts/sync-upstream.sh](../../scripts/sync-upstream.sh).
- Script performs the documented sync ritual for `main`: fetch `upstream`, checkout `main`, fast-forward merge from `upstream/main`, push `origin/main`.
- Script prints clear status messages and exits non-zero on failure.
- Script checks for required remotes and fails with a helpful message if `origin` or `upstream` is missing.
- Document the helper in [README.md](../../README.md) or another obvious operator-facing doc section if a better location is more appropriate.

## Out of scope (what's NOT in)

- Rebasing feature branches automatically.
- Windows PowerShell sync helper.
- Changing the branch model or git workflow rules.
- Any product code under `lib/`.

## Files likely to change

- [scripts/sync-upstream.sh](../../scripts/sync-upstream.sh)
- [README.md](../../README.md)

## Acceptance criteria

- [ ] Running `bash scripts/sync-upstream.sh` from the repo root performs the documented `main` sync ritual or fails safely with a clear message.
- [ ] The script never creates merge commits on `main`; it uses fast-forward-only semantics.
- [ ] Missing-remote and non-clean-state failures are explained in human-readable output.
- [ ] A short doc note points maintainers at the helper instead of forcing them to retype the ritual manually.

## Upstream-rebase impact

This is low-risk. The only upstream-owned file likely touched is `README.md`, and that change should be limited to a small maintainer-facing note. The new script lives in a fork-owned path, which keeps future upstream merges clean.

## Risk

The main risk is encoding unsafe git behavior into the helper. The script must not hide a non-fast-forward situation, auto-resolve conflicts, or mutate feature branches. A clean, explicit failure is better than “helpful” automation here.

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
- [x] Branch created: `feat/scaffold/P0-3-sync-helper-script`

### `coding → review` (Coder)
- [ ] `flutter analyze --fatal-infos` clean
- [ ] `flutter test` green
- [ ] Cross-platform check done (at minimum Linux)
- [ ] No unexpected outbound network destination
- [ ] PR description references ticket id
- [ ] Upstream-rebase impact section filled in PR template

### `review → done` (Supervisor)
- [ ] PR template checklist clean
- [ ] No drive-by refactors
- [ ] Branch rebased on latest main
- [ ] FF-only merge into main
- [ ] Ticket marked `state: done`

## Notes

The repo is operated from Windows today, but the primary runtime target for maintenance is Kali/Linux. Optimize for a simple bash-based flow that works in Git Bash, WSL, or a Linux shell.
