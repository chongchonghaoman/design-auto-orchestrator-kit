param(
  [string]$CodexHome = "",
  [string]$SourceCache = "",
  [switch]$SkipOpenDesign
)

$ErrorActionPreference = "Continue"

if (-not $CodexHome) {
  $CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
}

if (-not $SourceCache) {
  $defaultSourceCache = Join-Path $CodexHome "design-skill-sources"
  $sourceCacheCandidates = @()
  if ($env:DESIGN_SKILL_SOURCE_CACHE) {
    $sourceCacheCandidates += $env:DESIGN_SKILL_SOURCE_CACHE
  }
  $sourceCacheCandidates += $defaultSourceCache
  $sourceCacheCandidates += Get-PSDrive -PSProvider FileSystem | ForEach-Object {
    Join-Path $_.Root "codex-design-skill-sources"
  }

  $SourceCache = $sourceCacheCandidates |
    Where-Object { $_ -and (Test-Path -LiteralPath $_) } |
    Select-Object -First 1

  if (-not $SourceCache) {
    $SourceCache = $defaultSourceCache
  }
}

$skillRoot = Join-Path $CodexHome "skills"

function Test-PathResult {
  param([string]$Name, [string]$Path)
  [pscustomobject]@{
    Check = $Name
    OK = Test-Path -LiteralPath $Path
    Detail = $Path
  }
}

$results = @()
$results += Test-PathResult "skill ui-ux-pro-max" (Join-Path $skillRoot "ui-ux-pro-max\SKILL.md")
$results += Test-PathResult "skill hallmark" (Join-Path $skillRoot "hallmark\SKILL.md")
$results += Test-PathResult "skill better-icons" (Join-Path $skillRoot "better-icons\SKILL.md")
$results += Test-PathResult "skill ui-design-brain" (Join-Path $skillRoot "ui-design-brain\SKILL.md")
$results += Test-PathResult "skill web-design-guidelines" (Join-Path $skillRoot "web-design-guidelines\SKILL.md")
$results += Test-PathResult "skill frontend-design" (Join-Path $skillRoot "frontend-design\SKILL.md")
$results += Test-PathResult "skill design-taste-frontend" (Join-Path $skillRoot "design-taste-frontend\SKILL.md")
$results += Test-PathResult "skill impeccable" (Join-Path $skillRoot "impeccable\SKILL.md")
$results += Test-PathResult "skill design-auto-orchestrator" (Join-Path $skillRoot "design-auto-orchestrator\SKILL.md")
$results += Test-PathResult "source cache" $SourceCache

$betterIcons = Get-Command better-icons -ErrorAction SilentlyContinue
$results += [pscustomobject]@{
  Check = "cli better-icons"
  OK = [bool]$betterIcons
  Detail = if ($betterIcons) { $betterIcons.Source } else { "not found on PATH" }
}

if (-not $SkipOpenDesign) {
  $od = Get-Command od -ErrorAction SilentlyContinue
  $results += [pscustomobject]@{
    Check = "cli od"
    OK = [bool]$od
    Detail = if ($od) { $od.Source } else { "not found on PATH" }
  }

  try {
    $health = Invoke-WebRequest -UseBasicParsing -Uri "http://127.0.0.1:7456/api/health" -TimeoutSec 5
    $results += [pscustomobject]@{
      Check = "open-design daemon"
      OK = ($health.StatusCode -eq 200)
      Detail = $health.Content
    }
  } catch {
    $results += [pscustomobject]@{
      Check = "open-design daemon"
      OK = $false
      Detail = $_.Exception.Message
    }
  }

  try {
    $mcp = codex -c 'service_tier="fast"' mcp get open-design 2>&1
    $results += [pscustomobject]@{
      Check = "codex mcp open-design"
      OK = ($LASTEXITCODE -eq 0)
      Detail = ($mcp | Select-Object -First 2) -join " "
    }
  } catch {
    $results += [pscustomobject]@{
      Check = "codex mcp open-design"
      OK = $false
      Detail = $_.Exception.Message
    }
  }
}

try {
  $searchScript = Join-Path $skillRoot "ui-ux-pro-max\scripts\search.py"
  $uiux = python $searchScript "SaaS dashboard" --domain style -n 1 2>&1
  $results += [pscustomobject]@{
    Check = "ui-ux-pro-max search"
    OK = ($LASTEXITCODE -eq 0)
    Detail = ($uiux | Select-Object -First 1) -join ""
  }
} catch {
  $results += [pscustomobject]@{
    Check = "ui-ux-pro-max search"
    OK = $false
    Detail = $_.Exception.Message
  }
}

try {
  $icons = better-icons search home --prefix lucide --limit 1 --json 2>&1
  $results += [pscustomobject]@{
    Check = "better-icons search"
    OK = ($LASTEXITCODE -eq 0)
    Detail = ($icons | Select-Object -First 1) -join ""
  }
} catch {
  $results += [pscustomobject]@{
    Check = "better-icons search"
    OK = $false
    Detail = $_.Exception.Message
  }
}

$results | Format-Table -AutoSize

if ($results.OK -contains $false) {
  exit 1
}
