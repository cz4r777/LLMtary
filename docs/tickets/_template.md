---
id: <e.g. L1-1>
workstream: <WS1 local-only | WS2 kali-cli | WS3 branding | WS4 new-modules | WS0 scaffold>
title: <one line>
state: scoping
owner_supervisor: cz4r777
owner_coder: unassigned
created: <YYYY-MM-DD>
updated: <YYYY-MM-DD>
upstream_files_touched: []   # list of files that exist in upstream chetstriker/LLMtary — these will conflict on rebase
fork_only_files: []          # list of files that exist only in this fork — no rebase risk
---

# <ticket-id> — <title>

## Why

<!-- 1-3 paragraphs. The user-visible or operational problem being solved. Link to PLAN.md workstream and ROADMAP.md ticket id. -->

## Scope (what's in)

<!-- Concrete change list. Each item should map to a diff hunk a reviewer can point at. -->

-
-

## Out of scope (what's NOT in)

<!-- Prevent scope creep mid-coding. -->

-
-

## Files likely to change

<!-- Use link syntax: [path](../path). Mark upstream-owned files clearly. -->

- [`...`](../../...)

## Acceptance criteria

<!-- Testable from outside the diff. Reviewer reads these without looking at the code. -->

- [ ]
- [ ]

## Upstream-rebase impact

<!-- Which of upstream's seams does this touch? Why is this the right seam? What conflict resolution should the maintainer expect on next upstream sync? -->

## Risk

<!-- What could go wrong. OPSEC implications if any (cloud egress, telemetry, etc.). -->

## Handover checklist

### `scoping → ready` (Supervisor)
- [ ] Title concrete
- [ ] Workstream + id set
- [ ] Acceptance criteria testable from outside diff
- [ ] Out-of-scope listed
- [ ] Files-likely-to-change listed
- [ ] Upstream-rebase impact filled
- [ ] Prompt rule check (if `prompt_templates.dart` touched)
- [ ] Naming rule check (if user-visible strings touched)

### `ready → coding` (Coder)
- [ ] Ticket re-read cold
- [ ] CLAUDE.md / PLAN.md / CONTRIBUTING.md read
- [ ] Branch created: `feat/<workstream-short>/<ticket-id>-<slug>`

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

<!-- Anything the Coder needs that doesn't fit above. -->
