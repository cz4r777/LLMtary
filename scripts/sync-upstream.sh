#!/usr/bin/env bash
#
# sync-upstream.sh — fork maintenance helper.
#
# Performs the documented upstream sync ritual for the cz4r777/LLMtary
# (Millarty) fork:
#
#     fetch upstream
#     checkout main
#     fast-forward merge from upstream/main
#     push origin main
#
# Refuses to operate if:
#   - the `origin` or `upstream` remote is not configured
#   - the working tree is dirty (uncommitted changes or untracked files)
#   - HEAD is detached
#   - upstream/main cannot be fast-forwarded into local main
#
# Out of scope: rebasing feature branches. Run that step manually after
# this script completes. See CONTRIBUTING.md for the full ritual.

set -euo pipefail

err() {
  printf 'sync-upstream: ERROR: %s\n' "$*" >&2
  exit 1
}

log() {
  printf 'sync-upstream: %s\n' "$*"
}

git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || err "not inside a git working tree"

git remote get-url origin >/dev/null 2>&1 \
  || err "remote 'origin' is not configured. Add it: git remote add origin <fork-url>"

git remote get-url upstream >/dev/null 2>&1 \
  || err "remote 'upstream' is not configured. Add it: git remote add upstream https://github.com/chetstriker/LLMtary.git"

if ! git diff-index --quiet HEAD --; then
  err "working tree has uncommitted changes. Commit or stash them before syncing."
fi

if [ -n "$(git ls-files --others --exclude-standard)" ]; then
  err "working tree has untracked files. Commit, stash, or .gitignore them before syncing."
fi

orig_branch="$(git symbolic-ref --short HEAD 2>/dev/null || true)"
if [ -z "$orig_branch" ]; then
  err "HEAD is detached. Check out a branch before running."
fi

log "fetching upstream..."
git fetch upstream

log "checking out main..."
git checkout main

log "fast-forwarding main from upstream/main..."
if ! git merge --ff-only upstream/main; then
  err "non-fast-forward sync needed. Local main has commits that aren't on upstream/main. Resolve manually."
fi

log "pushing origin main..."
git push origin main

if [ "$orig_branch" != "main" ]; then
  log "returning to original branch: $orig_branch"
  git checkout "$orig_branch"
fi

log "done. main is in sync with upstream/main."
