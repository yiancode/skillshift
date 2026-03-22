---
name: skillshift
description: Migrate Claude assets to Codex, including skills, slash commands, plugins, MCP snapshots, subagents, hooks, templates, and settings. Use when user asks to convert/sync/migrate Claude setup to Codex.
---

# SkillShift

Use this skill when the user asks to migrate/convert/sync Claude setup into Codex.

## What This Skill Does

1. Backs up current Codex migration targets.
2. Fully syncs Claude skills to Codex skills.
3. Migrates Claude slash commands and converts them into Codex prompt files.
4. Migrates common Claude assets:
   - plugins
   - hooks
   - subagents/agents
   - templates
   - MCP/settings snapshots
5. Rewrites common hardcoded Claude paths to Codex paths.
6. Provides read-only validation.

## Run

macOS/Linux:

```bash
bash ~/.codex/skills/skillshift/scripts/migrate.sh
```

Windows (PowerShell):

```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\skills\skillshift\scripts\migrate.ps1"
```

Validation only (no writes):

```bash
bash ~/.codex/skills/skillshift/scripts/check.sh
```

## Output You Must Report

After running, report:

1. Backup path.
2. Skills/slash commands migration status.
3. plugins/mcp/subagents/hooks/templates migration status.
4. Path rewrite completion status.
5. Verify lines for key modules.
6. Whether migration is successful.

## Notes

- This workflow uses `rsync -a --delete`, so destination will mirror source.
- If environment blocks writing to `~/.codex`, ask the user to run the command locally and paste terminal output.
- `check.sh` is read-only and safe for quick health checks.
