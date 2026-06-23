[CmdletBinding()]
param(
  [string]$CodexHome = "",
  [string]$SourceCache = "",
  [switch]$Force,
  [switch]$SkipOpenDesign,
  [switch]$SkipGlobalTools
)

$ErrorActionPreference = "Stop"

if (-not $CodexHome) {
  $CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
}

if (-not $SourceCache) {
  $SourceCache = Join-Path $CodexHome "design-skill-sources"
}

$SkillRoot = Join-Path $CodexHome "skills"
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$OpenDesignReady = $false
$Warnings = New-Object System.Collections.Generic.List[string]

function Write-Step {
  param([string]$Message)
  Write-Host "[design-auto] $Message" -ForegroundColor Cyan
}

function Write-Warn {
  param([string]$Message)
  $script:Warnings.Add($Message) | Out-Null
  Write-Host "[design-auto][warn] $Message" -ForegroundColor Yellow
}

function New-TempDir {
  $path = Join-Path ([System.IO.Path]::GetTempPath()) ("design-auto-" + [System.Guid]::NewGuid().ToString("N"))
  New-Item -ItemType Directory -Force -Path $path | Out-Null
  return $path
}

function Join-RepoPath {
  param([string]$Root, [string]$RelativePath)
  if ([string]::IsNullOrWhiteSpace($RelativePath) -or $RelativePath -eq ".") {
    return $Root
  }
  $current = $Root
  foreach ($part in ($RelativePath -split '[\\/]' | Where-Object { $_ })) {
    $current = Join-Path $current $part
  }
  return $current
}

function Copy-SkillDirectory {
  param(
    [string]$Source,
    [string]$Name
  )

  $skillMd = Join-Path $Source "SKILL.md"
  if (-not (Test-Path -LiteralPath $skillMd)) {
    throw "SKILL.md not found in $Source"
  }

  New-Item -ItemType Directory -Force -Path $SkillRoot | Out-Null
  $dest = Join-Path $SkillRoot $Name
  if (Test-Path -LiteralPath $dest) {
    if ($Force) {
      Remove-Item -LiteralPath $dest -Recurse -Force
    } else {
      Write-Step "skip existing skill: $Name"
      return
    }
  }

  Copy-Item -LiteralPath $Source -Destination $dest -Recurse
  Write-Step "installed skill: $Name"
}

function Update-CodexAgentsGuardrail {
  $guardrailScript = Join-Path $SkillRoot "design-auto-orchestrator\scripts\install-guardrail.ps1"
  if (-not (Test-Path -LiteralPath $guardrailScript)) {
    throw "guardrail installer missing: $guardrailScript"
  }

  & powershell -NoProfile -ExecutionPolicy Bypass -File $guardrailScript -CodexHome $CodexHome -SkillRoot $SkillRoot
  if ($LASTEXITCODE -ne 0) {
    throw "guardrail installer failed with exit code $LASTEXITCODE"
  }

  Write-Step "updated Codex AGENTS guardrail"
}

function Get-GitHubZipRoot {
  param([string]$OwnerRepo, [string]$Ref = "main")

  $parts = $OwnerRepo.Split("/")
  if ($parts.Count -ne 2) {
    throw "OwnerRepo must look like owner/repo: $OwnerRepo"
  }

  $tmp = New-TempDir
  $zip = Join-Path $tmp "repo.zip"
  $url = "https://codeload.github.com/$($parts[0])/$($parts[1])/zip/$Ref"
  Invoke-WebRequest -UseBasicParsing -Uri $url -OutFile $zip
  Expand-Archive -LiteralPath $zip -DestinationPath $tmp -Force

  $dirs = Get-ChildItem -LiteralPath $tmp -Directory
  if ($dirs.Count -lt 1) {
    throw "No directory found after extracting $OwnerRepo"
  }

  return @{ Root = $dirs[0].FullName; Temp = $tmp }
}

function Install-GitHubSkill {
  param(
    [string]$OwnerRepo,
    [string]$RepoPath,
    [string]$Name,
    [string]$Ref = "main"
  )

  $dest = Join-Path $SkillRoot $Name
  if ((Test-Path -LiteralPath $dest) -and -not $Force) {
    Write-Step "skip existing skill: $Name"
    return
  }

  Write-Step "installing $Name from $OwnerRepo/$RepoPath"
  $download = Get-GitHubZipRoot -OwnerRepo $OwnerRepo -Ref $Ref
  try {
    $src = Join-RepoPath -Root $download.Root -RelativePath $RepoPath
    Copy-SkillDirectory -Source $src -Name $Name
  } finally {
    Remove-Item -LiteralPath $download.Temp -Recurse -Force -ErrorAction SilentlyContinue
  }
}

function Install-UiUxProMax {
  $name = "ui-ux-pro-max"
  $dest = Join-Path $SkillRoot $name
  if ((Test-Path -LiteralPath $dest) -and -not $Force) {
    Write-Step "skip existing skill: $name"
    return
  }

  if (-not (Get-Command npx -ErrorAction SilentlyContinue)) {
    throw "npx is required to install ui-ux-pro-max. Install Node.js/npm first."
  }

  Write-Step "installing ui-ux-pro-max via uipro-cli"
  $tmp = New-TempDir
  try {
    Push-Location $tmp
    & npx -y uipro-cli init --ai codex --force
    if ($LASTEXITCODE -ne 0) {
      throw "uipro-cli failed with exit code $LASTEXITCODE"
    }
    Pop-Location

    $src = Join-Path $tmp ".codex\skills\ui-ux-pro-max"
    Copy-SkillDirectory -Source $src -Name $name
  } finally {
    if ((Get-Location).Path -eq $tmp) {
      Pop-Location
    }
    Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
  }
}

function Ensure-NpmGlobal {
  param([string]$Command, [string]$Package)
  if ($SkipGlobalTools) {
    Write-Step "skip global tool install: $Package"
    return
  }
  if (Get-Command $Command -ErrorAction SilentlyContinue) {
    Write-Step "global tool already available: $Command"
    return
  }
  if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Warn "npm not found; cannot install global tool $Package"
    return
  }
  Write-Step "installing global npm tool: $Package"
  & npm install -g $Package
  if ($LASTEXITCODE -ne 0) {
    Write-Warn "npm install -g $Package failed"
  }
}

function Sync-SourceRepo {
  param([string]$Name, [string]$Url)
  New-Item -ItemType Directory -Force -Path $SourceCache | Out-Null
  $dest = Join-Path $SourceCache $Name

  if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Warn "git not found; cannot sync source repo $Name"
    return
  }

  if (Test-Path -LiteralPath $dest) {
    Write-Step "updating source cache: $Name"
    & git -C $dest pull --ff-only --quiet
    if ($LASTEXITCODE -ne 0) {
      Write-Warn "git pull failed for $Name"
    }
  } else {
    Write-Step "cloning source cache: $Name"
    & git clone --depth 1 --filter=blob:none --quiet $Url $dest
    if ($LASTEXITCODE -ne 0) {
      Write-Warn "git clone failed for $Name"
    }
  }
}

function Get-NodeMajor {
  if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    return 0
  }
  $version = (& node --version).Trim()
  if ($version -match '^v(\d+)\.') {
    return [int]$Matches[1]
  }
  return 0
}

function Ensure-Pnpm {
  if (Get-Command pnpm -ErrorAction SilentlyContinue) {
    return $true
  }
  if ($SkipGlobalTools) {
    Write-Warn "pnpm not found and -SkipGlobalTools was set"
    return $false
  }
  if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Warn "npm not found; cannot install pnpm"
    return $false
  }
  Write-Step "installing pnpm@10.33.2"
  & npm install -g pnpm@10.33.2
  return ($LASTEXITCODE -eq 0)
}

function Ensure-OpenDesignDaemon {
  try {
    $health = Invoke-WebRequest -UseBasicParsing -Uri "http://127.0.0.1:7456/api/health" -TimeoutSec 3
    if ($health.StatusCode -eq 200) {
      Write-Step "Open Design daemon already healthy"
      return $true
    }
  } catch {}

  $od = Get-Command od -ErrorAction SilentlyContinue
  if (-not $od) {
    Write-Warn "od CLI not found; cannot start Open Design daemon"
    return $false
  }

  Write-Step "starting Open Design daemon"
  $logDir = Join-Path $SourceCache ".open-design-run"
  New-Item -ItemType Directory -Force -Path $logDir | Out-Null
  $out = Join-Path $logDir "od-out.log"
  $err = Join-Path $logDir "od-err.log"
  Start-Process -FilePath "powershell.exe" -ArgumentList @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $od.Source, "--no-open") -WindowStyle Hidden -RedirectStandardOutput $out -RedirectStandardError $err | Out-Null

  for ($i = 0; $i -lt 30; $i++) {
    Start-Sleep -Seconds 1
    try {
      $health = Invoke-WebRequest -UseBasicParsing -Uri "http://127.0.0.1:7456/api/health" -TimeoutSec 3
      if ($health.StatusCode -eq 200) {
        Write-Step "Open Design daemon healthy"
        return $true
      }
    } catch {}
  }

  Write-Warn "Open Design daemon did not become healthy within 30 seconds"
  return $false
}

function Ensure-CodexOpenDesignMcp {
  if (-not (Get-Command codex -ErrorAction SilentlyContinue)) {
    Write-Warn "codex CLI not found; cannot configure Open Design MCP"
    return
  }

  & codex -c 'service_tier="fast"' mcp get open-design *> $null
  if ($LASTEXITCODE -eq 0) {
    Write-Step "Codex MCP open-design already configured"
    return
  }

  Write-Step "adding Codex MCP open-design"
  & codex -c 'service_tier="fast"' mcp add open-design -- od mcp --daemon-url http://127.0.0.1:7456
  if ($LASTEXITCODE -ne 0) {
    Write-Warn "failed to add Codex MCP open-design"
  }
}

function Install-OpenDesign {
  if ($SkipOpenDesign) {
    Write-Step "skip Open Design install"
    return $false
  }

  $odDir = Join-Path $SourceCache "open-design"
  if (-not (Test-Path -LiteralPath $odDir)) {
    Write-Warn "Open Design source cache missing; cannot build od"
    return $false
  }

  $nodeMajor = Get-NodeMajor
  if ($nodeMajor -lt 24) {
    Write-Warn "Open Design requires Node 24.x; detected major version $nodeMajor. Skipping od build."
    return $false
  }

  if (-not (Ensure-Pnpm)) {
    Write-Warn "pnpm unavailable; skipping Open Design build"
    return $false
  }

  try {
    Push-Location $odDir
    if ((-not (Test-Path -LiteralPath (Join-Path $odDir "node_modules"))) -or $Force) {
      Write-Step "installing Open Design dependencies"
      & pnpm install
      if ($LASTEXITCODE -ne 0) {
        throw "pnpm install failed"
      }
    } else {
      Write-Step "Open Design dependencies already present"
    }

    Write-Step "linking od CLI"
    & npm link
    if ($LASTEXITCODE -ne 0) {
      throw "npm link failed"
    }
  } catch {
    Write-Warn "Open Design setup failed: $($_.Exception.Message)"
    return $false
  } finally {
    Pop-Location
  }

  $daemonOk = Ensure-OpenDesignDaemon
  if ($daemonOk) {
    Ensure-CodexOpenDesignMcp
  }
  return $daemonOk
}

Write-Step "Codex home: $CodexHome"
Write-Step "Source cache: $SourceCache"
New-Item -ItemType Directory -Force -Path $SkillRoot | Out-Null

Write-Step "installing orchestrator"
Copy-SkillDirectory -Source (Join-Path $RepoRoot "skills\design-auto-orchestrator") -Name "design-auto-orchestrator"
Update-CodexAgentsGuardrail

Write-Step "installing downstream skills"
Install-UiUxProMax
Install-GitHubSkill -OwnerRepo "Nutlope/hallmark" -RepoPath "skills/hallmark" -Name "hallmark"
Install-GitHubSkill -OwnerRepo "better-auth/better-icons" -RepoPath "skills" -Name "better-icons"
Install-GitHubSkill -OwnerRepo "carmahhawwari/ui-design-brain" -RepoPath "." -Name "ui-design-brain"
Install-GitHubSkill -OwnerRepo "vercel-labs/agent-skills" -RepoPath "skills/web-design-guidelines" -Name "web-design-guidelines"
Install-GitHubSkill -OwnerRepo "anthropics/skills" -RepoPath "skills/frontend-design" -Name "frontend-design"
Install-GitHubSkill -OwnerRepo "Leonxlnx/taste-skill" -RepoPath "skills/taste-skill" -Name "design-taste-frontend"
Install-GitHubSkill -OwnerRepo "pbakaus/impeccable" -RepoPath "plugin/skills/impeccable" -Name "impeccable"

Ensure-NpmGlobal -Command "better-icons" -Package "better-icons"

Write-Step "syncing source cache"
$sourceRepos = @(
  @{ Name = "ui-ux-pro-max-skill"; Url = "https://github.com/nextlevelbuilder/ui-ux-pro-max-skill.git" },
  @{ Name = "taste-skill"; Url = "https://github.com/Leonxlnx/taste-skill.git" },
  @{ Name = "hallmark"; Url = "https://github.com/Nutlope/hallmark.git" },
  @{ Name = "awesome-design-skills"; Url = "https://github.com/bergside/awesome-design-skills.git" },
  @{ Name = "better-icons"; Url = "https://github.com/better-auth/better-icons.git" },
  @{ Name = "ui-design-brain"; Url = "https://github.com/carmahhawwari/ui-design-brain.git" },
  @{ Name = "anthropics-skills"; Url = "https://github.com/anthropics/skills.git" },
  @{ Name = "vercel-agent-skills"; Url = "https://github.com/vercel-labs/agent-skills.git" },
  @{ Name = "designer-skills"; Url = "https://github.com/Owl-Listener/designer-skills.git" },
  @{ Name = "impeccable-upstream"; Url = "https://github.com/pbakaus/impeccable.git" }
)

if (-not $SkipOpenDesign) {
  $sourceRepos += @{ Name = "open-design"; Url = "https://github.com/nexu-io/open-design.git" }
}

foreach ($repo in $sourceRepos) {
  Sync-SourceRepo -Name $repo.Name -Url $repo.Url
}

$OpenDesignReady = Install-OpenDesign

Write-Step "running health check"
$healthScript = Join-Path $SkillRoot "design-auto-orchestrator\scripts\health-check.ps1"
$healthArgs = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $healthScript, "-CodexHome", $CodexHome, "-SourceCache", $SourceCache)
if ($SkipOpenDesign -or -not $OpenDesignReady) {
  $healthArgs += "-SkipOpenDesign"
}

& powershell @healthArgs
if ($LASTEXITCODE -ne 0) {
  Write-Warn "health check reported failures"
}

if ($Warnings.Count -gt 0) {
  Write-Host ""
  Write-Host "Warnings:" -ForegroundColor Yellow
  foreach ($warning in $Warnings) {
    Write-Host "- $warning" -ForegroundColor Yellow
  }
}

Write-Host ""
Write-Host "Design Auto Orchestrator install complete. Restart Codex to load new skills." -ForegroundColor Green
