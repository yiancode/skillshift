# Claude Skills Migrator

A Codex skill that migrates all Claude skills from `~/.claude/skills` to `~/.codex/skills`.

## Features

- Backup existing Codex skills before migration
- Full sync with `rsync` (including scripts, assets, symlinks)
- Rewrite hardcoded path references from Claude to Codex
- Read-only verification mode

## Files

- `SKILL.md`: skill metadata and workflow guidance
- `scripts/migrate.sh`: full migration script
- `scripts/check.sh`: read-only validation script

## Usage

```bash
# Run migration
bash ~/.codex/skills/claude-skills-migrator/scripts/migrate.sh

# Validation only
bash ~/.codex/skills/claude-skills-migrator/scripts/check.sh
```

## Safety

- `migrate.sh` uses `rsync -a --delete`; destination mirrors source.
- The script creates a timestamped backup of `~/.codex/skills` before sync.

## Example Output

```text
[1/4] Backup created: /Users/<you>/.codex/skills.backup.YYYYMMDD-HHMMSS
[2/4] Full sync completed
[3/4] Path rewrite completed
[4/4] Verify: source dirs=29, target dirs=29
[OK] Migration finished.
```
