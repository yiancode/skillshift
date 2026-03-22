param(
  [string]$ClaudeHome = "$HOME/.claude",
  [string]$CodexHome = "$HOME/.codex"
)

$ErrorActionPreference = "Stop"

$srcSkills = Join-Path $ClaudeHome "skills"
$dstSkills = Join-Path $CodexHome "skills"

$srcCommands = Join-Path $ClaudeHome "commands"
$dstCommandsRaw = Join-Path $CodexHome "vendor_imports/claude/commands"
$dstCommandPrompts = Join-Path $CodexHome "prompts/claude-slash"

$srcPlugins = Join-Path $ClaudeHome "plugins"
$dstPlugins = Join-Path $CodexHome "vendor_imports/claude/plugins"

$srcHooks = Join-Path $ClaudeHome "hooks"
$dstHooks = Join-Path $CodexHome "vendor_imports/claude/hooks"

$srcSubagents = Join-Path $ClaudeHome "subagents"
$srcAgents = Join-Path $ClaudeHome "agents"
$dstSubagents = Join-Path $CodexHome "vendor_imports/claude/subagents"

$srcTemplates = Join-Path $ClaudeHome "templates"
$dstTemplates = Join-Path $CodexHome "vendor_imports/claude/templates"

$dstMcp = Join-Path $CodexHome "vendor_imports/claude/mcp"
$dstSettings = Join-Path $CodexHome "vendor_imports/claude/settings"

$ts = Get-Date -Format "yyyyMMdd-HHmmss"
$backup = Join-Path $CodexHome "claude-migration-backup.$ts"

if (-not (Test-Path $ClaudeHome)) {
  throw "Source not found: $ClaudeHome"
}

New-Item -ItemType Directory -Force -Path $CodexHome | Out-Null
New-Item -ItemType Directory -Force -Path $backup | Out-Null

function Sync-DirIfExists {
  param([string]$src, [string]$dst)
  if (Test-Path $src) {
    New-Item -ItemType Directory -Force -Path $dst | Out-Null
    if (Get-Command robocopy -ErrorAction SilentlyContinue) {
      robocopy $src $dst /MIR /R:2 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
    } else {
      Copy-Item -Path (Join-Path $src "*") -Destination $dst -Recurse -Force
    }
    Write-Host "  - synced: $src -> $dst"
  } else {
    Write-Host "  - skipped (not found): $src"
  }
}

Write-Host "[1/6] Migrate skills"
Sync-DirIfExists $srcSkills $dstSkills

Write-Host "[2/6] Migrate slash commands"
Sync-DirIfExists $srcCommands $dstCommandsRaw
New-Item -ItemType Directory -Force -Path $dstCommandPrompts | Out-Null
if (Test-Path $srcCommands) {
  Get-ChildItem -Path $srcCommands -Recurse -File -Filter "*.md" | ForEach-Object {
    $rel = $_.FullName.Substring($srcCommands.Length).TrimStart('\','/')
    $safe = $rel -replace '[\\/]', '__'
    $out = Join-Path $dstCommandPrompts $safe
    $content = @(
      "# Migrated Claude Slash Command"
      ""
      "- Source: ``$($_.FullName)``"
      "- Original slash path: ``/$rel``"
      ""
      (Get-Content -Path $_.FullName -Raw)
    ) -join "`n"
    Set-Content -Path $out -Value $content -Encoding UTF8
  }
}

Write-Host "[3/6] Migrate plugins / hooks / subagents / templates"
Sync-DirIfExists $srcPlugins $dstPlugins
Sync-DirIfExists $srcHooks $dstHooks
if (Test-Path $srcSubagents) {
  Sync-DirIfExists $srcSubagents $dstSubagents
} elseif (Test-Path $srcAgents) {
  Sync-DirIfExists $srcAgents $dstSubagents
} else {
  Write-Host "  - skipped (not found): $srcSubagents / $srcAgents"
}
Sync-DirIfExists $srcTemplates $dstTemplates

Write-Host "[4/6] Snapshot MCP + settings"
New-Item -ItemType Directory -Force -Path $dstMcp | Out-Null
New-Item -ItemType Directory -Force -Path $dstSettings | Out-Null

$settingFiles = @(
  (Join-Path $HOME ".claude.json"),
  (Join-Path $ClaudeHome "config.json"),
  (Join-Path $ClaudeHome "settings.json"),
  (Join-Path $ClaudeHome "settings.local.json"),
  (Join-Path $ClaudeHome "CLAUDE.md")
)

foreach ($f in $settingFiles) {
  if (Test-Path $f) {
    Copy-Item -Path $f -Destination $dstSettings -Force
  }
}

if (Test-Path (Join-Path $HOME ".claude.json")) {
  Copy-Item -Path (Join-Path $HOME ".claude.json") -Destination $dstMcp -Force
}

Write-Host "[5/6] Rewrite paths in migrated text files"
Get-ChildItem -Path $CodexHome -Recurse -File -Include *.md,*.txt,*.py,*.sh,*.js,*.ts,*.json,*.yaml,*.yml | ForEach-Object {
  $raw = Get-Content -Path $_.FullName -Raw
  $raw = $raw -replace "~/.claude/skills", "~/.codex/skills"
  $raw = $raw -replace "~/.claude/", "~/.codex/vendor_imports/claude/"
  $raw = $raw -replace "/Users/yian/.claude/skills", "/Users/yian/.codex/skills"
  Set-Content -Path $_.FullName -Value $raw -Encoding UTF8
}

Write-Host "[6/6] Done"
Write-Host "  backup: $backup"
Write-Host "[OK] Migration finished."

