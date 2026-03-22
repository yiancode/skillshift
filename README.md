# SkillShift

[English](README.en.md) | [中文（简体）](README.zh-CN.md)

将 Claude 本地能力体系迁移到 Codex 的实用工具集。它不仅迁移 `skills`，还覆盖常见 Claude 资产（slash commands、plugins、MCP、subagents、hooks、templates、settings），并提供校验能力。

## 适用场景

- 想把 `~/.claude` 的能力迁到 `~/.codex`
- 切换主力工具到 Codex，但不想手工重建配置
- 需要可回滚、可验证的迁移流程

## 迁移范围

| 类型 | Claude 源路径 | Codex 目标路径 | 说明 |
|---|---|---|---|
| Skills | `~/.claude/skills` | `~/.codex/skills` | `migrate.sh` 会排除 `skillshift` 与 `.system` |
| Slash Commands（原始） | `~/.claude/commands` | `~/.codex/vendor_imports/claude/commands` | 原样归档 |
| Slash Commands（转换） | `~/.claude/commands/*.md` | `~/.codex/prompts/claude-slash/` | 自动包装成 Codex prompt 文件 |
| Plugins | `~/.claude/plugins` | `~/.codex/vendor_imports/claude/plugins` | 目录镜像 |
| Hooks | `~/.claude/hooks` | `~/.codex/vendor_imports/claude/hooks` | 目录镜像 |
| Subagents / Agents | `~/.claude/subagents` 或 `~/.claude/agents` | `~/.codex/vendor_imports/claude/subagents` | 二选一迁移 |
| Templates | `~/.claude/templates` | `~/.codex/vendor_imports/claude/templates` | 目录镜像 |
| Settings 快照 | `~/.claude.json` 等 | `~/.codex/vendor_imports/claude/settings` | 配置归档 |
| MCP 快照 | `~/.claude.json` / 其他配置 | `~/.codex/vendor_imports/claude/mcp` | `jq` 可用时提取 MCP 摘要 |

## 前置条件

- macOS / Linux：`bash` + `rsync`
- Windows：PowerShell（优先 `robocopy`，不存在则回退 `Copy-Item`）
- 可选：`jq`（用于从 `.claude.json` 提取 MCP servers 摘要）

## 快速开始

```bash
# 1) 执行完整迁移（macOS / Linux）
bash ~/.codex/skills/skillshift/scripts/migrate.sh

# 2) 只读校验（不会写入）
bash ~/.codex/skills/skillshift/scripts/check.sh
```

```powershell
# Windows PowerShell 完整迁移
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\skills\skillshift\scripts\migrate.ps1"
```

## 迁移后如何验证

脚本输出会包含：

- 备份目录路径（例如：`~/.codex/claude-migration-backup.YYYYMMDD-HHMMSS`）
- skills 与 slash commands 迁移统计
- plugins / hooks / subagents / templates 迁移状态
- path rewrite 完成提示
- 关键模块计数（可通过 `check.sh` 复核）

## 安全与回滚

- `migrate.sh` 对目标目录使用 `rsync -a --delete`，目标会镜像源目录。
- 在 macOS/Linux 下会先备份 Codex 既有迁移目标再执行同步。
- 建议先运行 `check.sh` 了解当前源/目标规模，再执行迁移。
- 回滚时可从备份目录恢复需要的子目录。

## 已知差异

- `migrate.sh`（macOS/Linux）包含“迁移前备份 + 7 步输出”。
- `migrate.ps1`（Windows）流程为 6 步，行为接近但并非逐行等价实现。

## 仓库结构

- `SKILL.md`：技能元信息与操作规范
- `scripts/migrate.sh`：macOS/Linux 完整迁移
- `scripts/migrate.ps1`：Windows PowerShell 完整迁移
- `scripts/check.sh`：只读校验脚本

## 示例输出

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
