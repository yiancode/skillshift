---
name: skillshift
description: Migrate all Claude skills from ~/.claude/skills into ~/.codex/skills with backup, full sync, and path rewrite. Use when user asks to convert/sync/migrate Claude skills to Codex.
---

# SkillShift

Use this skill when the user asks to migrate/convert/sync Claude skills into Codex skills.

## What This Skill Does

1. Backs up current Codex skills directory.
2. Fully syncs `~/.claude/skills` to `~/.codex/skills`.
3. Rewrites hardcoded Claude skill paths in text files to Codex paths.
4. Verifies source/target skill directory counts.

## Run

Execute:

```bash
bash ~/.codex/skills/skillshift/scripts/migrate.sh
```

Validation only (no writes):

```bash
bash ~/.codex/skills/skillshift/scripts/check.sh
```

## Output You Must Report

After running, report:

1. Backup path.
2. Sync completion status.
3. Path rewrite completion status.
4. Verify line: `source dirs=<n>, target dirs=<n>`.
5. Whether migration is successful.

## Notes

- This workflow uses `rsync -a --delete`, so destination will mirror source.
- If environment blocks writing to `~/.codex`, ask the user to run the command locally and paste terminal output.
- `check.sh` is read-only and safe for quick health checks.
