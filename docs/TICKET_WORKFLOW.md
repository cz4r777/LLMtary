# Millarty — Ticket Workflow

> Defines how tickets move from idea to merged in this fork. Modelled on stingray's `docs/tickets.md` discipline but adapted for Millarty (Flutter desktop fork that tracks upstream chetstriker/LLMtary, no live-service deploy).
>
> **Source of truth** for what to build = [ROADMAP.md](../ROADMAP.md).
> **Source of truth** for how to build it = [PLAN.md](../PLAN.md) + [CONTRIBUTING.md](../CONTRIBUTING.md) + upstream's [CLAUDE.md](../CLAUDE.md).
> **This doc** defines the lifecycle every individual ticket walks.

---

## Roles

| Role | Who | Authority |
|---|---|---|
| **Supervisor** | this thread (Windows-side Claude) + the human operator | Writes/scopes tickets. Reviews PRs. Decides when a ticket is `done`. Owns the upstream sync ritual. |
| **Coder** | a separate Claude session (or the operator with a Claude assistant) on a feature branch | Implements one ticket end-to-end. Opens the PR. Returns a handover-back when the PR is open. Does **not** scope tickets and does **not** self-approve. |
| **Reviewer** | Supervisor in a second pass (must be a separate pass, even when the same human) | Reads the PR cold against the gate. Sends back to `coding` on a block; never approves their own diff. |

The Supervisor → Coder handover is an [ASCII-box single-block handover](../PLAN.md) — one fenced block the operator copy-pastes into the Coder session.

---

## States

| State | Owner | Meaning |
|---|---|---|
| `scoping` | Supervisor | Drafted, not frozen. Shape may change. |
| `ready` | Supervisor | Scope frozen. Acceptance criteria written. Awaiting a Coder. |
| `coding` | Coder | Branch cut, implementation in progress. |
| `review` | Reviewer | PR open. |
| `done` | Supervisor | PR merged to `main` (via fast-forward from feature branch), CI green, manual smoke pass. |
| `blocked` | (whoever last touched it) | Cannot proceed; reason MUST name what unblocks it. |
| `abandoned` | Supervisor | Closed without shipping. Reason MUST be written. |

No `staging`/`prod` states — Millarty is a desktop app the operator runs locally on Kali. "Smoke pass" means: `flutter analyze`, `flutter test`, then a manual run against a known lab target on at least one platform (Linux primary, Windows/macOS where applicable).

---

## Flow

```
   scoping ──► ready ──► coding ──► review ──► done
                            ▲           │
                            └───────────┘   (Reviewer sends back on block)

   blocked     <── any state
   abandoned   <── any state (Supervisor only)
```

---

## Branch model

- One ticket = one branch.
- Branch name: `feat/<workstream-short>/<ticket-id>-<slug>` — e.g. `feat/local-only/L1-1-localOnlyMode-constant`.
- Workstream shorts: `local-only`, `kali-cli`, `branding`, `new-modules`, `scaffold` (WS0).
- Ticket IDs come from [ROADMAP.md](../ROADMAP.md) (`P0-N`, `L1-N`, `K2-N`, `B3-N`, `M4-N`, `X-N`).
- PR title = `[<ticket-id>] <title>`.
- PR body references the ticket and walks the `coding → review` gate inline.

---

## Handover gates

### `scoping → ready` (Supervisor signs off)

- [ ] Title is concrete (no "improve X")
- [ ] Workstream + ticket id from ROADMAP.md set
- [ ] Acceptance criteria are testable from outside the diff
- [ ] Out-of-scope items listed
- [ ] Files-likely-to-change listed
- [ ] Upstream-rebase impact noted: which upstream files touched and why this seam is the right one
- [ ] **Prompt rule check** — if the ticket touches `lib/services/prompt_templates.dart` or `lib/services/vulnerability_analyzer.dart`, the upstream rules from CLAUDE.md are restated in the ticket: no tool names, no specific CVE IDs, objective-first framing, platform-neutral language
- [ ] **Naming rule check** — if the ticket touches user-visible strings: confirm the change goes through `kAppDisplayName` / theme assets, **never** a global `LLMtary` → `Millarty` rename in code

### `ready → coding` (Coder picks up)

- [ ] Coder has re-read the ticket cold (not from supervisor's verbal summary)
- [ ] Coder has read [CLAUDE.md](../CLAUDE.md), [PLAN.md](../PLAN.md), [CONTRIBUTING.md](../CONTRIBUTING.md)
- [ ] Branch created per the branch-model section
- [ ] If this is an AI Coder, Supervisor knows it (per two-Claude architecture pattern)

### `coding → review` (Coder opens PR)

- [ ] `flutter analyze --fatal-infos` clean
- [ ] `flutter test` green
- [ ] Cross-platform requirement honoured ([CLAUDE.md §Cross-Platform Requirement](../CLAUDE.md)) — Linux verified at minimum; Windows/macOS verified if the change touches command execution or platform-sensitive paths
- [ ] No new outbound network destination unless the ticket explicitly adds one
- [ ] If local-only mode is in scope: provider gating still holds after the change
- [ ] PR description names the ticket id and links to it
- [ ] Upstream-rebase impact section filled in PR template

### `review → done` (Supervisor merges)

- [ ] PR template checklist clean
- [ ] No drive-by refactors of unrelated files
- [ ] `main` is fast-forwardable from feature branch (i.e. branch was rebased on latest main before merge)
- [ ] Merge into `main` via `--ff-only` so the FF-from-upstream invariant is preserved
- [ ] Ticket file updated to `state: done`

---

## File layout

```
docs/
  TICKET_WORKFLOW.md       this doc
  tickets/
    _template.md           the per-ticket template
    L1-1-local-only-mode-constant.md
    L1-2-llm-service-gate.md
    ...
```

Tickets live as markdown files. The Supervisor copies `_template.md`, allocates the ticket id from ROADMAP.md, and fills it in.

---

## Conventions

- **One ticket = one branch = one PR.** No stacked-ticket PRs.
- **No verbal scope.** If it isn't in the ticket file, it isn't in scope.
- **A failed gate is a state regression.** A ticket at `review` whose Reviewer says "no" flips back to `coding`, not to `ready`. The ticket stays alive through the rework.
- **Ids are monotonic per workstream.** L1-1, L1-2, L1-3 — never reused, never renumbered.
- **The Supervisor writes the handover; the Coder does not write their own kickoff.** The handover is the ticket's `ready → coding` artifact.
- **The Coder produces the handback** when the PR is open: a short ASCII-box reply naming the PR url, the gate-walk result, and any open questions.
