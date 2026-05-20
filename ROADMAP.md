# Millarty — Roadmap

Phased ticket breakdown for the workstreams in [PLAN.md](PLAN.md). Millarty is the user-facing name of the `cz4r777/LLMtary` fork; the internal package stays `llmtary` for upstream-sync sanity. Tickets are ordered by dependency, not calendar.

> The state machine and handover gates each ticket walks are defined in [docs/TICKET_WORKFLOW.md](docs/TICKET_WORKFLOW.md). The per-ticket file template is [docs/tickets/_template.md](docs/tickets/_template.md).

## Phase 0 — Fork scaffold (active)

- [x] **P0-1** — Add `upstream` remote, confirm fork is in sync.
- [x] **P0-2** — `PLAN.md`, `ROADMAP.md`, `.github/` templates, CI workflow.
- [ ] **P0-3** — `make sync` or `scripts/sync-upstream.sh` helper for the upstream merge ritual.
- [ ] **P0-4** — `CONTRIBUTING.md` capturing the branch model (so future-me doesn't forget).

## Phase 1 — WS1 Local-only / Ollama-hardened

- [ ] **L1-1** — Add `kLocalOnlyMode` constant + persisted setting in `AppState`.
- [ ] **L1-2** — Gate `LlmService` provider construction behind the flag; throw on cloud provider when local-only is true.
- [ ] **L1-3** — Settings UI: toggle + lock banner ("Local-only mode active — cloud providers disabled").
- [ ] **L1-4** — Network egress test: under local-only mode, instantiating cloud clients raises; `flutter test` asserts.
- [ ] **L1-5** — Make local-only the default on first launch when `LLMTARY_PROFILE=kali` env var is set (sets up WS2).

## Phase 2 — WS2 Kali / Linux server mode

- [ ] **K2-1** — Extract analyzer + executor wiring from `AppState` into a `Session` class (UI-agnostic). UI consumes it via `Provider`; CLI consumes it directly.
- [ ] **K2-2** — Create `bin/llmtary_cli.dart` entrypoint with `args` package (target, rules, out-dir, profile).
- [ ] **K2-3** — Output writers: report files, SQLite DB to specified out-dir; no GUI calls.
- [ ] **K2-4** — Wrapper script `scripts/llmtary-cli` + install instructions for Kali.
- [ ] **K2-5** — Smoke test against an internal lab box; verify report parity with GUI run.

## Phase 3 — WS3 Branding & reporting overhaul

- [ ] **B3-1** — Define theme tokens (color palette, fonts, logo path) in `assets/branding/theme.yaml`.
- [ ] **B3-2** — Extract report HTML/CSS into templates under `assets/branding/templates/`; refactor `report_generator.dart` to consume them.
- [ ] **B3-3** — Add `--branding=<dir>` CLI flag + GUI dropdown to swap branding bundle at runtime.
- [ ] **B3-4** — Add `kAppDisplayName = "Millarty"` constant; route window/app titles through it. No global rename of `LLMtary` → `Millarty` in code.
- [ ] **B3-5** — Optional: alternative installer artifact name (keeps upstream installer scripts intact).

## Phase 4 — WS4 New attack modules

- [ ] **M4-1** — Decide module priority. Suggested order: cloud-native/K8s → container escapes → AI/ML pipelines → mobile API → IoT.
- [ ] **M4-2** — Cloud-native/K8s prompt set + analyzer registration with indicator gate (`k8s`, `kubernetes`, `kubelet`, port `10250`, `/api/v1/namespaces` in HTTP responses).
- [ ] **M4-3** — Container escape prompt set with indicator gate (docker socket, `/.dockerenv`, cgroup detection).
- [ ] **M4-4** — Tests in `test/prompt_integration_test.dart` for each new module.
- [ ] **M4-5** — Lab validation run (kube-goat or equivalent).

---

## Cross-cutting

- [ ] **X-1** — GitHub Actions: `flutter analyze` + `flutter test` on PRs (see `.github/workflows/ci.yml`).
- [ ] **X-2** — Optional secondary CI job for the Dart CLI build (`dart compile exe bin/llmtary_cli.dart`) once WS2 lands.
- [ ] **X-3** — Document the upstream-sync ritual in `CONTRIBUTING.md` so it doesn't get lost.
