#!/usr/bin/env bash
set -euo pipefail

SRC="$HOME/.claude/skills"
DST="$HOME/.codex/skills"
TS="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/.codex/skills.backup.$TS"

if [[ ! -d "$SRC" ]]; then
  echo "[ERROR] Source not found: $SRC" >&2
  exit 1
fi

mkdir -p "$DST"

mkdir -p "$BACKUP"
rsync -a "$DST/" "$BACKUP/"
echo "[1/4] Backup created: $BACKUP"

rsync -a --delete --exclude '.DS_Store' "$SRC/" "$DST/"
echo "[2/4] Full sync completed"

find "$DST" -type f \( \
  -name 'SKILL.md' -o -name '*.md' -o -name '*.txt' -o \
  -name '*.py' -o -name '*.sh' -o -name '*.js' -o -name '*.ts' -o \
  -name '*.json' -o -name '*.yaml' -o -name '*.yml' \
\) -print0 | xargs -0 perl -pi -e 's#~/.claude/skills#~/.codex/skills#g; s#/Users/yian/.claude/skills#/Users/yian/.codex/skills#g'
echo "[3/4] Path rewrite completed"

SRC_COUNT="$(find "$SRC" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
DST_COUNT="$(find "$DST" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
echo "[4/4] Verify: source dirs=$SRC_COUNT, target dirs=$DST_COUNT"

if [[ "$SRC_COUNT" != "$DST_COUNT" ]]; then
  echo "[WARN] Directory count mismatch. Please check manually."
  exit 2
fi

echo "[OK] Migration finished."

