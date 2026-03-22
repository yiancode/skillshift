#!/usr/bin/env bash
set -euo pipefail

SRC="$HOME/.claude/skills"
DST="$HOME/.codex/skills"

if [[ ! -d "$SRC" ]]; then
  echo "[ERROR] Source not found: $SRC" >&2
  exit 1
fi

if [[ ! -d "$DST" ]]; then
  echo "[ERROR] Target not found: $DST" >&2
  exit 1
fi

echo "[1/5] Basic path check: OK"

SRC_DIRS="$(find "$SRC" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
DST_DIRS="$(find "$DST" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
echo "[2/5] Top-level dirs: source=$SRC_DIRS target=$DST_DIRS"

MISSING_IN_DST="$(comm -23 \
  <(find -L "$SRC" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort) \
  <(find -L "$DST" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort) || true)"

EXTRA_IN_DST="$(comm -13 \
  <(find -L "$SRC" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort) \
  <(find -L "$DST" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort) || true)"

echo "[3/5] Missing dirs in target:"
if [[ -n "$MISSING_IN_DST" ]]; then
  echo "$MISSING_IN_DST"
else
  echo "(none)"
fi

echo "[4/5] Extra dirs in target:"
if [[ -n "$EXTRA_IN_DST" ]]; then
  echo "$EXTRA_IN_DST"
else
  echo "(none)"
fi

KEY_SKILLS=(wechat-publisher pdf2pptx pptx mermaid-tools skill-creator)
echo "[5/5] Key skill file-count check:"
for s in "${KEY_SKILLS[@]}"; do
  c1="$(find "$SRC/$s" -type f 2>/dev/null | wc -l | tr -d ' ')"
  c2="$(find "$DST/$s" -type f 2>/dev/null | wc -l | tr -d ' ')"
  echo "  - $s: source=$c1 target=$c2"
done

if [[ -z "$MISSING_IN_DST" ]]; then
  echo "[OK] Check finished."
else
  echo "[WARN] Check finished with missing target dirs."
  exit 2
fi

