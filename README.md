# SkillShift

[English](README.en.md)

一个用于 Codex 的技能，可将 Claude 的全部 skills 从 `~/.claude/skills` 迁移到 `~/.codex/skills`。
并支持迁移常用 Claude 生态能力（斜线指令、plugins、MCP、subagents、hooks 等）。

## 功能

- 迁移前自动备份现有 Codex skills
- 使用 `rsync` 全量同步（包含脚本、资源、符号链接）
- 自动改写文本中的路径引用（Claude -> Codex）
- 提供只读校验模式
- 支持迁移并归档：
  - slash commands（并转换为 Codex prompts）
  - plugins
  - MCP 配置快照
  - subagents/agents
  - hooks
  - templates / settings

## 文件说明

- `SKILL.md`：技能元数据与工作流说明
- `scripts/migrate.sh`：macOS/Linux 完整迁移
- `scripts/migrate.ps1`：Windows PowerShell 完整迁移
- `scripts/check.sh`：只读校验，不写入文件

## 使用方法

```bash
# 执行迁移
bash ~/.codex/skills/skillshift/scripts/migrate.sh

# 只做校验
bash ~/.codex/skills/skillshift/scripts/check.sh
```

```powershell
# Windows PowerShell 执行迁移
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\skills\skillshift\scripts\migrate.ps1"
```

## 安全说明

- `migrate.sh` 使用 `rsync -a --delete`，目标目录会镜像源目录。
- 脚本会先创建 `~/.codex/skills` 的时间戳备份再执行同步。
- 非 skill 的 Claude 资产会迁移到 `~/.codex/vendor_imports/claude/` 下，便于后续手动接入。

## 输出示例

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
