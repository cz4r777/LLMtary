# Millarty — Upgrade & Customization Plan

> **Project name:** Millarty (customization fork of upstream LLMtary).
> Working plan for the `cz4r777/LLMtary` fork shipped as Millarty. Tracks upstream `chetstriker/LLMtary`; all custom work lives on feature branches so upstream syncs stay clean. The "Millarty" name is applied via a branding/theme layer (WS3), **not** a global rename of `LLMtary` in code — that would destroy upstream rebase compatibility.

---

## Mission

Customize LLMtary for solo / small-team red-team work on a Kali server, with strong local-AI guarantees, custom branding, and additional attack-module coverage — without diverging so far from upstream that we lose access to its updates.

## Branch model

- `main` — fast-forward only from `upstream/main`. **No custom commits land here** other than fork-meta files (`PLAN.md`, `ROADMAP.md`, `.github/`). Everything else goes through feature branches.
- `feat/<workstream>` — long-lived branches per workstream below. Rebase on `main` after every upstream sync.
- `fix/<short>` / `chore/<short>` — short-lived branches for one-off fixes.

Sync ritual (run weekly or before starting new work):
```
git fetch upstream
git checkout main
git merge --ff-only upstream/main
git push origin main
# then rebase each active feat/* branch on main
```

## Remotes

- `origin`  = `https://github.com/cz4r777/LLMtary.git` (the fork)
- `upstream` = `https://github.com/chetstriker/LLMtary.git`

---

## Workstreams

### WS1 — Local-only / Ollama-hardened mode

**Goal:** guarantee no LLM traffic leaves the host when "Local-only" is on. Default to Ollama. Make accidental cloud egress impossible (not just unlikely).

**Touches**
- [lib/services/llm_service.dart](lib/services/llm_service.dart) — gate cloud providers behind a hard mode flag.
- [lib/constants/](lib/constants/) — add `kLocalOnlyMode` constant + persisted setting.
- [lib/screens/settings_screen.dart](lib/screens/settings_screen.dart) — UI toggle, with a banner when active.
- New: a settings-time validator that disables cloud provider dropdown entries when local-only is on.

**Exit criteria**
- With local-only on, picking Claude/ChatGPT/Gemini/OpenRouter is impossible from the UI and any code path that constructs a cloud HTTP client throws.
- A test asserts that under local-only mode, no `http.Client` is created targeting `api.anthropic.com`, `api.openai.com`, `generativelanguage.googleapis.com`, or `openrouter.ai`.

### WS2 — Kali / Linux server (headless) mode

**Goal:** run a recon → analysis → exploit pass with no GUI, so the Kali server can be the operating console.

**Touches**
- New: `bin/llmtary_cli.dart` entrypoint (Dart command-line app, not Flutter) consuming the same services.
- [lib/services/](lib/services/) — extract analyzer + executor wiring from `AppState` into a `Session` core so both UI and CLI consume it.
- New: `scripts/llmtary-cli` wrapper for the installed binary.
- `pubspec.yaml` — add `args` for arg parsing; the Flutter-dependent UI bits stay outside the CLI binary.

**Exit criteria**
- `dart run bin/llmtary_cli.dart --target 10.10.10.10 --rules ./rules.txt --out ./run/` produces the same SQLite DB and report files as a GUI run, with no Flutter window.
- Builds and runs on Kali (Linux x64). Tested over SSH.

### WS3 — Branding & reporting overhaul (Millarty)

**Goal:** reports and app chrome present as **Millarty**, not stock LLMtary. The rename is delivered through a theme/assets layer + a single `kAppDisplayName = "Millarty"` constant — **not** a global string replace — so upstream rebases keep applying cleanly.

**Touches**
- [lib/services/report_generator.dart](lib/services/report_generator.dart) + [lib/services/report_content_service.dart](lib/services/report_content_service.dart) — template layer; pull header/footer/CSS from a customizable theme file.
- New: `assets/branding/` — logo, color tokens, report HTML/CSS templates.
- [pubspec.yaml](pubspec.yaml) — register branding assets.
- App title / window title surfaced through a new `kAppDisplayName = "Millarty"` constant. Installer metadata ([LLMtary_Win_Installer.ifp](LLMtary_Win_Installer.ifp), [.metadata](.metadata), [linux/](linux/), [macos/](macos/), [windows/](windows/)) — touch only where the user-visible product name is rendered; leave the internal `llmtary` package name, binary name, and identifiers alone so installer/CI scripts inherited from upstream keep working.

**Exit criteria**
- Generated HTML report uses Millarty branding by default; can be swapped via a single `--branding=path/to/dir` flag (CLI) or settings dialog (GUI).
- App window/title read "Millarty" without changing the executable name, package identifier, or installer artifact paths (so upstream installer scripts keep working).

### WS4 — New attack modules / prompts

**Goal:** extend `PromptTemplates` coverage to areas we hit often but upstream is light on.

**Candidates (decide priority before starting):**
- Cloud-native / Kubernetes — pod escape, RBAC abuse, IMDS abuse beyond what `device_utils.dart` `CloudIndicators` covers.
- Container escapes — Docker socket exposure, capabilities, mount escapes.
- Mobile API backends — Android/iOS-flavored API testing prompts (cert pinning bypass detection, deeplink abuse, mobile-specific OAuth flows).
- IoT / embedded — UART/JTAG indicators, firmware hash matching, default-cred catalogs.
- AI/ML pipelines — prompt injection on exposed LLM endpoints, model-stealing endpoints, vector-DB exposure.

**Touches**
- [lib/services/prompt_templates.dart](lib/services/prompt_templates.dart) — new prompt sections; keep the "no tool names, no CVE IDs" rule from [CLAUDE.md](CLAUDE.md).
- [lib/services/vulnerability_analyzer.dart](lib/services/vulnerability_analyzer.dart) — register the new prompts behind indicator gates so they only fire on relevant targets.
- [test/prompt_integration_test.dart](test/prompt_integration_test.dart) — coverage tests.

**Exit criteria**
- New prompts fire only when their indicators are present (verified by test).
- Run on a known-vulnerable cloud-native lab (e.g. kube-goat) produces at least one confirmed finding from the new module.

---

## Risk & safety notes

- **Upstream rebase pain.** Renaming files or refactoring services into a Session core (WS2) will conflict heavily on upstream rebases. Keep these changes in self-contained new files where possible, and only modify upstream files at well-defined seams.
- **Branding diff sprawl.** Searching and replacing "LLMtary" → "Millarty" everywhere will create huge diffs and break every upstream merge. **The user-visible name is "Millarty"; the internal package, binary, and identifier name stays `llmtary`.** All Millarty-isms ship via the theme/assets layer and a single display-name constant.
- **Local-only mode must be the default for the Kali build.** A misconfigured cloud provider on a red-team engagement is an OPSEC failure. WS1 ships before WS2 leaves Kali.
- **No commits to `main` from feature work.** Even a typo fix on a prompt goes through a `fix/` branch — keeps `git rev-list main...upstream/main` clean for sync checks.

---

## Status board

| Workstream | Branch | State |
|---|---|---|
| WS0 — Fork scaffold (this doc, .github/) | _direct on main_ | in progress |
| WS1 — Local-only mode | `feat/local-only-mode` | not started |
| WS2 — Kali CLI mode | `feat/kali-cli` | not started |
| WS3 — Branding | `feat/branding` | not started |
| WS4 — New modules | `feat/new-modules` | not started |

See [ROADMAP.md](ROADMAP.md) for phased ticket breakdown.
