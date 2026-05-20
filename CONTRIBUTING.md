# Contributing to this fork

This is `cz4r777/LLMtary`, a customization fork of [`chetstriker/LLMtary`](https://github.com/chetstriker/LLMtary). The fork tracks upstream and isolates custom work on feature branches so upstream syncs stay clean.

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

Run weekly or before starting new work:

```
git fetch upstream
git checkout main
git merge --ff-only upstream/main
git push origin main

# rebase each active feat/* branch
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
