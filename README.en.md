# SkillShift

[中文](README.md) | [中文（备用）](README.zh-CN.md)

A practical migration toolkit for moving local Claude assets into Codex. It migrates not only `skills`, but also slash commands, plugins, MCP snapshots, subagents, hooks, templates, and settings snapshots.

## When To Use

- You want to move your local setup from `~/.claude` to `~/.codex`.
- You do not want to manually rebuild commands/plugins/MCP config.
- You want a migration flow with verification and rollback options.

## Migration Matrix

| Asset Type | Claude Source | Codex Target | Notes |
|---|---|---|---|
| Skills | `~/.claude/skills` | `~/.codex/skills` | `migrate.sh` excludes `skillshift` and `.system` |
| Slash Commands (raw) | `~/.claude/commands` | `~/.codex/vendor_imports/claude/commands` | Kept as archived source |
| Slash Commands (converted) | `~/.claude/commands/*.md` | `~/.codex/prompts/claude-slash/` | Converted into Codex prompt files |
| Plugins | `~/.claude/plugins` | `~/.codex/vendor_imports/claude/plugins` | Mirrored directory sync |
| Hooks | `~/.claude/hooks` | `~/.codex/vendor_imports/claude/hooks` | Mirrored directory sync |
| Subagents / Agents | `~/.claude/subagents` or `~/.claude/agents` | `~/.codex/vendor_imports/claude/subagents` | First available source is used |
| Templates | `~/.claude/templates` | `~/.codex/vendor_imports/claude/templates` | Mirrored directory sync |
| Settings snapshots | `.claude.json` and related files | `~/.codex/vendor_imports/claude/settings` | Snapshot copy |
| MCP snapshots | `.claude.json` / related config | `~/.codex/vendor_imports/claude/mcp` | Uses `jq` summary when available |

## Prerequisites

- macOS/Linux: `bash` and `rsync`
- Windows: PowerShell (prefers `robocopy`, falls back to `Copy-Item`)
- Optional: `jq` for MCP server summary extraction

## Quick Start

```bash
# Full migration (macOS/Linux)
bash ~/.codex/skills/skillshift/scripts/migrate.sh

# Read-only validation
bash ~/.codex/skills/skillshift/scripts/check.sh
```

```powershell
# Full migration (Windows PowerShell)
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\skills\skillshift\scripts\migrate.ps1"
```

## What To Verify After Migration

- Backup path is printed.
- Skills and slash-command prompt counts look expected.
- Plugins/hooks/subagents/templates are present under `vendor_imports/claude`.
- `check.sh` ends with `[OK] Check finished.`

## Safety And Rollback

- `migrate.sh` uses `rsync -a --delete`; destination mirrors source.
- On macOS/Linux, migration targets are backed up before sync.
- Restore from `~/.codex/claude-migration-backup.*` if rollback is needed.

## Platform Notes

- `migrate.sh` (macOS/Linux) is a 7-step flow with backup and verify counters.
- `migrate.ps1` (Windows) is equivalent in intent, but not line-by-line identical.

## Repository Layout

- `SKILL.md`: skill metadata and workflow contract
- `scripts/migrate.sh`: full migration for macOS/Linux
- `scripts/migrate.ps1`: full migration for Windows PowerShell
- `scripts/check.sh`: read-only validation script

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
