# SkillShift

[English](README.md)

一个用于 Codex 的技能，可将 Claude 的全部 skills 从 `~/.claude/skills` 迁移到 `~/.codex/skills`。

## 功能

- 迁移前自动备份现有 Codex skills
- 使用 `rsync` 全量同步（包含脚本、资源、符号链接）
- 自动改写文本中的路径引用（Claude -> Codex）
- 提供只读校验模式

## 文件说明

- `SKILL.md`：技能元数据与工作流说明
- `scripts/migrate.sh`：执行完整迁移
- `scripts/check.sh`：只读校验，不写入文件

## 使用方法

```bash
# 执行迁移
bash ~/.codex/skills/skillshift/scripts/migrate.sh

# 只做校验
bash ~/.codex/skills/skillshift/scripts/check.sh
```

## 安全说明

- `migrate.sh` 使用 `rsync -a --delete`，目标目录会镜像源目录。
- 脚本会先创建 `~/.codex/skills` 的时间戳备份再执行同步。

## 输出示例

```text
[1/4] Backup created: /Users/<you>/.codex/skills.backup.YYYYMMDD-HHMMSS
[2/4] Full sync completed
[3/4] Path rewrite completed
[4/4] Verify: source dirs=29, target dirs=29
[OK] Migration finished.
```
