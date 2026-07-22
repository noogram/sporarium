#!/usr/bin/env bash
# ============================================================================
# guard-no-github-surface.sh — R1-prime structural enforcement
# ============================================================================
#
# WHY THIS FILE EXISTS
# --------------------
# A maintainer governance deliberation (2026-07-21) asked: should sporarium couple its cosmon
# molecule backlog to the public GitHub issue tracker (noogram/sporarium) via
# the cosmon surface sync (kind = "github-issues")?
#
# Unanimous 5/5 verdict: DO NOT COUPLE. Adopt regime R1', "hand-curated
# decoupling, structurally enforced." The governance rule the panel inscribed
# is a single sentence:
#
#     "Sever the capability, don't gate the act."
#
# The reason is mechanical, not a matter of discipline. Every projected GitHub
# issue body carries an invisible marker `<!-- cosmon:molecule:{id} -->`. That
# marker is *simultaneously* (a) cosmon's dedup key and (b) a direct breach of
# the P4 confidentiality bar — it publishes an internal molecule ID into a
# public, indexed, un-previewable, one-way medium. Filtering changes the
# cardinality of the leak, never its kind (adversary). No sync regime available
# today can satisfy P4.
#
# A tombstone COMMENT is an intention, not a lock: `cs init` re-materializes an
# unfiltered surface and `auto_reconcile` fires it. So the panel demanded the
# absence be *actively defended* by a machine that FAILS THE BUILD if the wire
# is ever reconnected. This script is that machine.
#
# WHAT IT CHECKS (fail-closed)
# ----------------------------
# It FAILS LOUDLY (exit 1) when, AND ONLY WHEN, the git remote is public AND
# either of the following is true:
#
#   1. `.cosmon/surfaces.toml` declares a LIVE (non-commented) surface with
#      `kind = "github-issues"`.
#   2. `.cosmon/config.toml` (or surfaces.toml) sets `auto_reconcile = true`
#      under `[surfaces]`.
#
# Absence of surfaces.toml, or a fully-commented tombstone example, is the
# CORRECT R1' ship-state and PASSES.
#
# Note on file locality: in the current cosmon (verified against
# cosmon-core/src/config.rs and cosmon-surface/src/config.rs at cs 0.2.2),
# `kind = "github-issues"` lives in surfaces.toml and `auto_reconcile` lives in
# config.toml's [surfaces] table. The brief conflated the two into "surfaces.toml";
# this guard scans BOTH files for BOTH signals so it stays correct regardless of
# which file a future cosmon puts each field in.
#
# ---------------------------------------------------------------------------
# STANDING FALSIFIER (Popper — the one-way, cached refutation)
# ---------------------------------------------------------------------------
# R1' is a conjecture kept alive only by never being refuted. Its single
# falsifier is one-directional and un-erasable once fired:
#
#     ANY internal molecule ID appearing in a public noogram/sporarium issue
#     means the wire was reconnected — regime R1' is BROKEN.
#
# Concretely, watch the live GitHub tracker for:
#   * a `<!-- cosmon:molecule:... -->` marker in any issue body;
#   * a bare-id issue title (e.g. a 4-hex-char molecule suffix as a title);
#   * a `delib-YYYYMMDD-xxxx` or `task-YYYYMMDD-xxxx` slug in title or body.
#
# One hit = the capability was reintroduced somewhere this guard did not cover
# (a stray token, a hand-run `cs reconcile` against a live surface, a future
# cosmon field this parser does not know). It is a REFUTATION, not a warning:
# the confirming observation (no writes) is repeatable, the refuting one (an ID
# published) is one-way and cached by search engines. That asymmetry is why the
# corroboration test (runs/2026-07-22-r1prime-corroboration.md) runs in a
# sandbox BEFORE the real medium, never after.
#
# The maintainer is the SOLE actor who may create a public issue, by hand,
# after a P4 audit of the exact body. Reintroducing a github-issues surface is
# a deliberate human act that must first make this guard pass again.
#
# Full rationale: the maintainers' internal deliberation record (2026-07-21, not published).
# ============================================================================

set -euo pipefail

# --- locate the repo root (walk up from this script) -----------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

SURFACES_TOML=".cosmon/surfaces.toml"
CONFIG_TOML=".cosmon/config.toml"

fail() {
  echo "" >&2
  echo "  ✗ R1' STRUCTURAL GUARD FAILED — the GitHub-issues wire was reconnected." >&2
  echo "" >&2
  echo "    $1" >&2
  echo "" >&2
  echo "    Governance rule (maintainer deliberation, 2026-07-21): 'sever the capability, don't gate the act.'" >&2
  echo "    sporarium must NEVER auto-publish internal molecule IDs to its public" >&2
  echo "    GitHub tracker. The maintainer creates public issues BY HAND after a P4 audit." >&2
  echo "    Remove the live github-issues surface / auto_reconcile=true, or make the" >&2
  echo "    remote private, then re-run this guard. See the header of $0 for the full why." >&2
  echo "" >&2
  exit 1
}

# --- strip TOML comments so a commented tombstone/example never trips ------
# Removes everything from the first unquoted '#' to end-of-line. Our fields
# (kind values, owner/repo, booleans) never contain '#' inside quotes, so a
# naive strip is safe and avoids a TOML dependency the recipient may not have.
strip_comments() {
  # shellcheck disable=SC2001
  sed -e 's/#.*$//' "$1"
}

# --- is the git remote public? ---------------------------------------------
# Fail-closed: if we cannot prove the remote is PRIVATE, we treat it as public
# so the guard errs toward refusing the leak. A public forge host (github.com,
# gitlab.com, ...) is public unless `gh` can positively confirm visibility=private.
remote_is_public() {
  local url host_is_public_forge
  url="$(git remote get-url origin 2>/dev/null || true)"
  [ -z "$url" ] && return 1   # no remote at all → nothing public to leak into

  case "$url" in
    *github.com*|*gitlab.com*|*bitbucket.org*|*codeberg.org*|*sourcehut.org*|*sr.ht*)
      host_is_public_forge=1 ;;
    *)
      host_is_public_forge=0 ;;
  esac
  [ "$host_is_public_forge" -eq 0 ] && return 1  # self-hosted/unknown → not treated as public forge

  # Best-effort refinement: if gh is authed and the repo is positively private,
  # downgrade to "not public". Any error or "public"/"internal" keeps it public.
  if command -v gh >/dev/null 2>&1; then
    local vis
    vis="$(gh repo view --json visibility -q .visibility 2>/dev/null || true)"
    if [ "$vis" = "PRIVATE" ]; then
      return 1
    fi
  fi
  return 0
}

# --- scan for a LIVE github-issues surface ---------------------------------
has_live_github_surface() {
  [ -f "$SURFACES_TOML" ] || return 1
  # Quote-agnostic: TOML permits "double" or 'literal' strings; a hand-edit
  # could use either, so match both rather than only cosmon's double-quoted form.
  strip_comments "$SURFACES_TOML" \
    | grep -Eq "^[[:space:]]*kind[[:space:]]*=[[:space:]]*[\"']github-issues[\"'][[:space:]]*\$"
}

# --- scan for auto_reconcile = true (config.toml OR surfaces.toml) ----------
has_auto_reconcile() {
  local f
  for f in "$CONFIG_TOML" "$SURFACES_TOML"; do
    [ -f "$f" ] || continue
    if strip_comments "$f" \
        | grep -Eq '^[[:space:]]*auto_reconcile[[:space:]]*=[[:space:]]*true[[:space:]]*$'; then
      return 0
    fi
  done
  return 1
}

# --- main ------------------------------------------------------------------
echo "R1' guard: checking for reconnected GitHub-issues capability…"

if ! remote_is_public; then
  echo "  · origin is not a public forge (or is positively private) — guard is advisory here."
  # Still report findings, but do not fail: R1' targets PUBLIC leakage.
  if has_live_github_surface; then
    echo "  ⚠ note: a live github-issues surface exists, but the remote is not public. Not failing."
  fi
  if has_auto_reconcile; then
    echo "  ⚠ note: auto_reconcile = true, but the remote is not public. Not failing."
  fi
  echo "  ✓ PASS (no public leak surface)."
  exit 0
fi

echo "  · origin is a PUBLIC remote — enforcing R1' strictly."

if has_live_github_surface; then
  fail "Found a LIVE 'kind = \"github-issues\"' surface in $SURFACES_TOML."
fi

if has_auto_reconcile; then
  fail "Found 'auto_reconcile = true' (in $CONFIG_TOML or $SURFACES_TOML)."
fi

echo "  ✓ PASS — no live github-issues surface, no auto_reconcile. The wire is severed."
exit 0
