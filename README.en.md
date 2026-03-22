# SkillShift

[中文](README.md)

A Codex skill that migrates Claude setup to Codex, including skills, slash commands, plugins, MCP snapshots, subagents, hooks, templates, and settings.

## Features

- Backup existing Codex skills before migration
- Full sync with `rsync` (including scripts, assets, symlinks)
- Rewrite hardcoded path references from Claude to Codex
- Read-only verification mode
- Migration support for common Claude assets:
  - slash commands (converted to Codex prompts)
  - plugins
  - MCP config snapshots
  - subagents/agents
  - hooks
  - templates / settings

## Files

- `SKILL.md`: skill metadata and workflow guidance
- `scripts/migrate.sh`: full migration script for macOS/Linux
- `scripts/migrate.ps1`: full migration script for Windows PowerShell
- `scripts/check.sh`: read-only validation script

## Usage

```bash
# Run migration
bash ~/.codex/skills/skillshift/scripts/migrate.sh

# Validation only
bash ~/.codex/skills/skillshift/scripts/check.sh
```

```powershell
# Windows PowerShell migration
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\skills\skillshift\scripts\migrate.ps1"
```

## Safety

- `migrate.sh` uses `rsync -a --delete`; destination mirrors source.
- The script creates a timestamped backup of `~/.codex/skills` before sync.
- Non-skill Claude assets are migrated to `~/.codex/vendor_imports/claude/`.

## Example Output

```text
[1/7] Backup current Codex targets...
[2/7] Migrate skills...
[3/7] Migrate slash commands...
[4/7] Migrate plugins / hooks / subagents / templates...
[5/7] Migrate MCP and settings snapshots...
[6/7] Rewrite hardcoded paths in migrated text files...
[7/7] Verify...
[OK] Migration finished.
```
