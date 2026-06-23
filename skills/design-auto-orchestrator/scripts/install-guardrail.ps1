param(
  [string]$CodexHome = "",
  [string]$SkillRoot = ""
)

$ErrorActionPreference = "Stop"

if (-not $CodexHome) {
  $CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
}

if (-not $SkillRoot) {
  $SkillRoot = Join-Path $CodexHome "skills"
}

$agentsPath = Join-Path $CodexHome "AGENTS.md"
$begin = "<!-- design-auto-orchestrator:begin -->"
$end = "<!-- design-auto-orchestrator:end -->"
$skillPath = Join-Path $SkillRoot "design-auto-orchestrator\SKILL.md"

if (-not (Test-Path -LiteralPath $skillPath)) {
  $localSkillPath = Resolve-Path (Join-Path $PSScriptRoot "..\SKILL.md") -ErrorAction SilentlyContinue
  if ($localSkillPath) {
    $skillPath = $localSkillPath.Path
  }
}

$block = @"
$begin
## Design Orchestrator Guardrail

For any task that touches UI, UX, frontend visuals, websites, landing pages,
portfolios, dashboards, admin panels, app screens, components, forms, tables,
navigation, design systems, typography, color, layout, motion, icons,
accessibility, responsive behavior, screenshot critique, visual polish,
anti-AI-slop, Open Design, or design-resource selection, first open and read:

$skillPath

This is mandatory even when another specific skill such as frontend-design,
hallmark, ui-ux-pro-max, ui-design-brain, web-design-guidelines,
better-icons, pdf, playwright, stitch-design, or open-design also
matches the request.

Do not begin design implementation until the orchestrator has classified the
task and selected the downstream route. For websites, portfolios, and landing
pages, a responsive/layout pass is not enough: inspect screenshots for taste,
specificity, credibility, and audience fit before final delivery.
$end
"@

New-Item -ItemType Directory -Force -Path $CodexHome | Out-Null
$existing = if (Test-Path -LiteralPath $agentsPath) {
  Get-Content -Raw -LiteralPath $agentsPath
} else {
  ""
}

$escapedBegin = [regex]::Escape($begin)
$escapedEnd = [regex]::Escape($end)
$pattern = "(?s)$escapedBegin.*?$escapedEnd"

if ($existing -match $pattern) {
  $updated = [regex]::Replace($existing, $pattern, [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $block.TrimEnd() }, 1)
} elseif ([string]::IsNullOrWhiteSpace($existing)) {
  $updated = $block.TrimEnd() + [Environment]::NewLine
} else {
  $updated = $existing.TrimEnd() + [Environment]::NewLine + [Environment]::NewLine + $block.TrimEnd() + [Environment]::NewLine
}

Set-Content -LiteralPath $agentsPath -Value $updated -Encoding UTF8
Write-Host "Design orchestrator guardrail installed: $agentsPath"
