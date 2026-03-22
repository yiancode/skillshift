# Claude Skills Migrator

A Codex skill that migrates all Claude skills from `~/.claude/skills` to `~/.codex/skills`.

## Features

- Backup existing Codex skills before migration
- Full sync with `rsync` (including scripts/assets/symlinks)
- Rewrite hardcoded path references from Claude to Codex
- Read-only verification mode

## Project Structure

- `SKILL.md`: skill trigger metadata and workflow instructions
- `scripts/migrate.sh`: full migration script
- `scripts/check.sh`: read-only validation script

## Usage

### 1. Install into Codex skills directory

```bash
mkdir -p ~/.codex/skills/claude-skills-migrator
cp -R ./* ~/.codex/skills/claude-skills-migrator/
chmod +x ~/.codex/skills/claude-skills-migrator/scripts/*.sh
```

### 2. Run migration

```bash
bash ~/.codex/skills/claude-skills-migrator/scripts/migrate.sh
```

### 3. Run read-only check

```bash
bash ~/.codex/skills/claude-skills-migrator/scripts/check.sh
```

## Notes

- `migrate.sh` uses `rsync -a --delete`; target directory will mirror source.
- In restricted environments, run scripts directly in your local terminal.

## License

MIT (or your preferred license)
