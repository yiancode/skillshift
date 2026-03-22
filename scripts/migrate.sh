#!/usr/bin/env bash
set -euo pipefail

SRC_HOME="$HOME/.claude"
DST_HOME="$HOME/.codex"

SRC_SKILLS="$SRC_HOME/skills"
DST_SKILLS="$DST_HOME/skills"

SRC_COMMANDS="$SRC_HOME/commands"
DST_COMMANDS_RAW="$DST_HOME/vendor_imports/claude/commands"
DST_COMMAND_PROMPTS="$DST_HOME/prompts/claude-slash"

SRC_PLUGINS="$SRC_HOME/plugins"
DST_PLUGINS="$DST_HOME/vendor_imports/claude/plugins"

SRC_HOOKS="$SRC_HOME/hooks"
DST_HOOKS="$DST_HOME/vendor_imports/claude/hooks"

SRC_SUBAGENTS_1="$SRC_HOME/subagents"
SRC_SUBAGENTS_2="$SRC_HOME/agents"
DST_SUBAGENTS="$DST_HOME/vendor_imports/claude/subagents"

SRC_TEMPLATES="$SRC_HOME/templates"
DST_TEMPLATES="$DST_HOME/vendor_imports/claude/templates"

DST_MCP="$DST_HOME/vendor_imports/claude/mcp"
DST_SETTINGS="$DST_HOME/vendor_imports/claude/settings"

TS="$(date +%Y%m%d-%H%M%S)"
BACKUP="$DST_HOME/claude-migration-backup.$TS"

if [[ ! -d "$SRC_HOME" ]]; then
  echo "[ERROR] Source not found: $SRC_HOME" >&2
  exit 1
fi

mkdir -p "$DST_HOME" "$BACKUP"

backup_if_exists() {
  local src="$1"
  local name="$2"
  if [[ -e "$src" ]]; then
    mkdir -p "$BACKUP/$name"
    rsync -a "$src/" "$BACKUP/$name/" 2>/dev/null || rsync -a "$src" "$BACKUP/$name/"
  fi
}

sync_dir_if_exists() {
  local src="$1"
  local dst="$2"
  if [[ -d "$src" ]]; then
    mkdir -p "$dst"
    if [[ "$dst" == "$DST_SKILLS" ]]; then
      rsync -a --delete --exclude ".DS_Store" --exclude "skillshift" --exclude ".system" "$src/" "$dst/"
    else
      rsync -a --delete --exclude ".DS_Store" "$src/" "$dst/"
    fi
    echo "  - synced: $src -> $dst"
  else
    echo "  - skipped (not found): $src"
  fi
}

echo "[1/7] Backup current Codex targets..."
backup_if_exists "$DST_SKILLS" "skills"
backup_if_exists "$DST_COMMANDS_RAW" "commands"
backup_if_exists "$DST_COMMAND_PROMPTS" "prompts_claude_slash"
backup_if_exists "$DST_PLUGINS" "plugins"
backup_if_exists "$DST_HOOKS" "hooks"
backup_if_exists "$DST_SUBAGENTS" "subagents"
backup_if_exists "$DST_TEMPLATES" "templates"
backup_if_exists "$DST_MCP" "mcp"
backup_if_exists "$DST_SETTINGS" "settings"
echo "  backup: $BACKUP"

echo "[2/7] Migrate skills..."
sync_dir_if_exists "$SRC_SKILLS" "$DST_SKILLS"

echo "[3/7] Migrate slash commands..."
sync_dir_if_exists "$SRC_COMMANDS" "$DST_COMMANDS_RAW"
mkdir -p "$DST_COMMAND_PROMPTS"
if [[ -d "$SRC_COMMANDS" ]]; then
  find "$SRC_COMMANDS" -type f -name "*.md" | while read -r file; do
    rel="${file#$SRC_COMMANDS/}"
    safe_name="$(echo "$rel" | sed 's#/#__#g')"
    out="$DST_COMMAND_PROMPTS/$safe_name"
    {
      echo "# Migrated Claude Slash Command"
      echo
      echo "- Source: \`$file\`"
      echo "- Original slash path: \`/$rel\`"
      echo
      cat "$file"
    } > "$out"
  done
  echo "  - converted markdown commands -> $DST_COMMAND_PROMPTS"
fi

echo "[4/7] Migrate plugins / hooks / subagents / templates..."
sync_dir_if_exists "$SRC_PLUGINS" "$DST_PLUGINS"
sync_dir_if_exists "$SRC_HOOKS" "$DST_HOOKS"
if [[ -d "$SRC_SUBAGENTS_1" ]]; then
  sync_dir_if_exists "$SRC_SUBAGENTS_1" "$DST_SUBAGENTS"
elif [[ -d "$SRC_SUBAGENTS_2" ]]; then
  sync_dir_if_exists "$SRC_SUBAGENTS_2" "$DST_SUBAGENTS"
else
  echo "  - skipped (not found): $SRC_SUBAGENTS_1 / $SRC_SUBAGENTS_2"
fi
sync_dir_if_exists "$SRC_TEMPLATES" "$DST_TEMPLATES"

echo "[5/7] Migrate MCP and settings snapshots..."
mkdir -p "$DST_MCP" "$DST_SETTINGS"
for f in \
  "$HOME/.claude.json" \
  "$SRC_HOME/config.json" \
  "$SRC_HOME/settings.json" \
  "$SRC_HOME/settings.local.json"; do
  if [[ -f "$f" ]]; then
    cp "$f" "$DST_SETTINGS/"
    echo "  - copied settings: $f"
  fi
done
if [[ -f "$SRC_HOME/CLAUDE.md" ]]; then
  cp "$SRC_HOME/CLAUDE.md" "$DST_SETTINGS/"
  echo "  - copied: $SRC_HOME/CLAUDE.md"
fi
if command -v jq >/dev/null 2>&1 && [[ -f "$HOME/.claude.json" ]]; then
  jq '.mcpServers // .mcp // {}' "$HOME/.claude.json" > "$DST_MCP/mcp_servers.json" || true
  echo "  - extracted MCP summary: $DST_MCP/mcp_servers.json"
else
  for f in "$HOME/.claude.json" "$SRC_HOME/config.json" "$SRC_HOME/settings.json"; do
    [[ -f "$f" ]] && cp "$f" "$DST_MCP/"
  done
  echo "  - copied raw MCP source configs"
fi

echo "[6/7] Rewrite hardcoded paths in migrated text files..."
find "$DST_HOME" -type f \( \
  -name "SKILL.md" -o -name "*.md" -o -name "*.txt" -o \
  -name "*.py" -o -name "*.sh" -o -name "*.js" -o -name "*.ts" -o \
  -name "*.json" -o -name "*.yaml" -o -name "*.yml" \
\) -print0 | xargs -0 perl -pi -e 's#~/.claude/#~/.codex/vendor_imports/claude/#g; s#~/.claude/skills#~/.codex/skills#g; s#/Users/yian/.claude/skills#/Users/yian/.codex/skills#g'
echo "  - rewrite completed"

echo "[7/7] Verify..."
SRC_SKILL_DIRS="$(find "$SRC_SKILLS" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')"
DST_SKILL_DIRS="$(find "$DST_SKILLS" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')"
SRC_CMD_FILES="$(find "$SRC_COMMANDS" -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')"
DST_CMD_FILES="$(find "$DST_COMMAND_PROMPTS" -type f -name '*.md' 2>/dev/null | wc -l | tr -d ' ')"
echo "  - skills dirs: source=$SRC_SKILL_DIRS target=$DST_SKILL_DIRS"
echo "  - slash commands(md): source=$SRC_CMD_FILES target_prompts=$DST_CMD_FILES"

echo "[OK] Migration finished."
