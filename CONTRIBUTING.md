# Contributing to Millarty

**Millarty** is the user-facing name of this customization fork of [`chetstriker/LLMtary`](https://github.com/chetstriker/LLMtary). The repo lives at `cz4r777/LLMtary`. The internal package name, binary name, and Dart package identifier all stay `llmtary` so we can keep pulling upstream cleanly — Millarty is delivered through a branding/theme layer plus a `kAppDisplayName` constant (see WS3 in [PLAN.md](PLAN.md)). The fork tracks upstream and isolates custom work on feature branches so upstream syncs stay clean.

## Branch model

- `main` — fast-forward only from `upstream/main`. Only fork-meta files land here directly (`PLAN.md`, `ROADMAP.md`, `.github/`, `CONTRIBUTING.md`).
- `feat/<workstream>` — long-lived per-workstream branches. Rebase on `main` after every upstream sync.
- `fix/<short>` / `chore/<short>` — short-lived branches.

## Remotes

```
origin    https://github.com/cz4r777/LLMtary.git    # the fork
upstream  https://github.com/chetstriker/LLMtary.git
```

If `upstream` isn't set:

```
git remote add upstream https://github.com/chetstriker/LLMtary.git
git fetch upstream
```

## Upstream sync ritual

Run weekly or before starting new work. The `main` portion of the ritual is wrapped in a helper script — use it instead of retyping the four git commands.

```
bash scripts/sync-upstream.sh
```

The helper fetches `upstream`, checks out `main`, fast-forwards from `upstream/main`, and pushes `origin/main`. It refuses to run on a dirty working tree, with a missing `origin` or `upstream` remote, or when a non-fast-forward sync would be required. See [scripts/sync-upstream.sh](scripts/sync-upstream.sh) for the full behaviour.

Rebasing feature branches stays manual — the helper deliberately does not touch them:

```
# after sync-upstream.sh succeeds, rebase each active feat/* branch
for b in feat/local-only-mode feat/kali-cli feat/branding feat/new-modules; do
  git checkout "$b" 2>/dev/null && git rebase main && git push --force-with-lease origin "$b"
done
```

If a fast-forward fails, something landed on `main` that shouldn't have. Move it onto a feature branch and reset `main` to `upstream/main`.

## Before opening a PR

```
flutter analyze
flutter test
```

PRs must:
1. Reference the workstream and ticket ID from [PLAN.md](PLAN.md) / [ROADMAP.md](ROADMAP.md).
2. Note upstream-rebase impact in the description.
3. Pass CI ([.github/workflows/ci.yml](.github/workflows/ci.yml)).

## Prompt-editing rules (from CLAUDE.md)

When editing `lib/services/prompt_templates.dart`:
- No specific tool names — say "enumerate SMB shares", not "run enum4linux".
- No specific CVE IDs — version-range matching only.
- Objective-first framing.
- Platform-neutral language.

These rules are inherited from upstream and apply to fork work too.
