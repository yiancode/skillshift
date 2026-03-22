# SkillShift

[English](README.en.md) | [中文默认](README.md)

一个用于将 Claude 本地资产迁移到 Codex 的工具。除 `skills` 外，还支持迁移 slash commands、plugins、MCP、subagents、hooks、templates 和 settings 快照。

## 适用场景

- 希望把 `~/.claude` 的能力体系迁移到 `~/.codex`
- 不想手动搬运 plugins / MCP / commands 等分散配置
- 需要可验证、可回滚的迁移流程

## 迁移范围

| 类型 | Claude 源路径 | Codex 目标路径 | 说明 |
|---|---|---|---|
| Skills | `~/.claude/skills` | `~/.codex/skills` | `migrate.sh` 会排除 `skillshift` 与 `.system` |
| Slash Commands（原始） | `~/.claude/commands` | `~/.codex/vendor_imports/claude/commands` | 原样归档 |
| Slash Commands（转换） | `~/.claude/commands/*.md` | `~/.codex/prompts/claude-slash/` | 转换为 Codex prompt 文件 |
| Plugins | `~/.claude/plugins` | `~/.codex/vendor_imports/claude/plugins` | 目录镜像 |
| Hooks | `~/.claude/hooks` | `~/.codex/vendor_imports/claude/hooks` | 目录镜像 |
| Subagents / Agents | `~/.claude/subagents` 或 `~/.claude/agents` | `~/.codex/vendor_imports/claude/subagents` | 自动择一路径 |
| Templates | `~/.claude/templates` | `~/.codex/vendor_imports/claude/templates` | 目录镜像 |
| Settings 快照 | `~/.claude.json` 等 | `~/.codex/vendor_imports/claude/settings` | 配置归档 |
| MCP 快照 | `~/.claude.json` / 其他配置 | `~/.codex/vendor_imports/claude/mcp` | `jq` 可用时提取摘要 |

## 前置条件

- macOS / Linux：`bash` + `rsync`
- Windows：PowerShell（优先 `robocopy`）
- 可选：`jq`（提取 MCP servers 摘要）

## 使用方法

```bash
# 完整迁移（macOS / Linux）
bash ~/.codex/skills/skillshift/scripts/migrate.sh

# 只读校验（不写入）
bash ~/.codex/skills/skillshift/scripts/check.sh
```

```powershell
# Windows PowerShell 完整迁移
powershell -ExecutionPolicy Bypass -File "$HOME\.codex\skills\skillshift\scripts\migrate.ps1"
```

## 验证与结果

迁移完成后建议检查：

- 备份目录路径是否输出
- `skills` 与 `prompts/claude-slash` 的计数是否合理
- plugins / hooks / subagents / templates 是否落在 `vendor_imports/claude`
- `check.sh` 输出是否为 `[OK] Check finished.`

## 安全说明

- `migrate.sh` 使用 `rsync -a --delete`，目标会镜像源目录。
- macOS/Linux 会先备份后同步。
- 如需回滚，可从 `~/.codex/claude-migration-backup.*` 恢复。

## 平台差异

- `migrate.sh`（macOS/Linux）是 7 步流程，含迁移前备份与 verify 统计。
- `migrate.ps1`（Windows）是等效迁移实现，但步骤与细节不完全一致。

## 文件说明

- `SKILL.md`：技能元数据与工作流
- `scripts/migrate.sh`：macOS/Linux 迁移脚本
- `scripts/migrate.ps1`：Windows 迁移脚本
- `scripts/check.sh`：只读校验脚本
