#!/usr/bin/env bash
set -euo pipefail

SRC_HOME="$HOME/.claude"
DST_HOME="$HOME/.codex"

report_count() {
  local label="$1"
  local src="$2"
  local dst="$3"
  local src_count=0
  local dst_count=0
  [[ -e "$src" ]] && src_count="$(find "$src" -type f 2>/dev/null | wc -l | tr -d ' ')"
  [[ -e "$dst" ]] && dst_count="$(find "$dst" -type f 2>/dev/null | wc -l | tr -d ' ')"
  echo "  - $label: source=$src_count target=$dst_count"
}

if [[ ! -d "$SRC_HOME" ]]; then
  echo "[ERROR] Source not found: $SRC_HOME" >&2
  exit 1
fi
if [[ ! -d "$DST_HOME" ]]; then
  echo "[ERROR] Target not found: $DST_HOME" >&2
  exit 1
fi

echo "[1/6] Path check: OK"

echo "[2/6] Skills + slash commands"
report_count "skills" "$SRC_HOME/skills" "$DST_HOME/skills"
report_count "slash commands(raw)" "$SRC_HOME/commands" "$DST_HOME/vendor_imports/claude/commands"
report_count "slash commands(prompts)" "$SRC_HOME/commands" "$DST_HOME/prompts/claude-slash"

echo "[3/6] Plugins / hooks / subagents / templates"
report_count "plugins" "$SRC_HOME/plugins" "$DST_HOME/vendor_imports/claude/plugins"
report_count "hooks" "$SRC_HOME/hooks" "$DST_HOME/vendor_imports/claude/hooks"
if [[ -d "$SRC_HOME/subagents" ]]; then
  report_count "subagents" "$SRC_HOME/subagents" "$DST_HOME/vendor_imports/claude/subagents"
elif [[ -d "$SRC_HOME/agents" ]]; then
  report_count "subagents(agents)" "$SRC_HOME/agents" "$DST_HOME/vendor_imports/claude/subagents"
else
  echo "  - subagents: source=0 target=$(find "$DST_HOME/vendor_imports/claude/subagents" -type f 2>/dev/null | wc -l | tr -d ' ')"
fi
report_count "templates" "$SRC_HOME/templates" "$DST_HOME/vendor_imports/claude/templates"

echo "[4/6] MCP + settings snapshots"
for f in ".claude.json" "config.json" "settings.json" "settings.local.json" "CLAUDE.md"; do
  srcf="$HOME/$f"
  [[ "$f" != ".claude.json" ]] && srcf="$SRC_HOME/$f"
  if [[ -f "$srcf" ]]; then
    base="$(basename "$srcf")"
    if [[ -f "$DST_HOME/vendor_imports/claude/settings/$base" || -f "$DST_HOME/vendor_imports/claude/mcp/$base" ]]; then
      echo "  - found snapshot: $base"
    else
      echo "  - missing snapshot: $base"
    fi
  fi
done

echo "[5/6] Key skill samples"
for s in wechat-publisher pdf2pptx pptx mermaid-tools skill-creator; do
  report_count "$s" "$SRC_HOME/skills/$s" "$DST_HOME/skills/$s"
done

echo "[6/6] Result"
echo "[OK] Check finished."

