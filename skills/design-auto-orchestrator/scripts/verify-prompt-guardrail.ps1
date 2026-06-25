param(
  [string]$Prompt = "build a personal portfolio website",
  [string]$OutFile = ""
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command codex -ErrorAction SilentlyContinue)) {
  throw "codex CLI not found on PATH"
}

$removeOutFile = $false
if (-not $OutFile) {
  $OutFile = Join-Path ([System.IO.Path]::GetTempPath()) ("design-auto-prompt-" + [System.Guid]::NewGuid().ToString("N") + ".json")
  $removeOutFile = $true
}

$errFile = Join-Path ([System.IO.Path]::GetTempPath()) ("design-auto-prompt-" + [System.Guid]::NewGuid().ToString("N") + ".err")

try {
  $previousErrorActionPreference = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  & codex -c 'service_tier="fast"' debug prompt-input $Prompt > $OutFile 2> $errFile
  $ErrorActionPreference = $previousErrorActionPreference

  if (-not (Test-Path -LiteralPath $OutFile) -or ((Get-Item -LiteralPath $OutFile).Length -eq 0)) {
    $stderr = if (Test-Path -LiteralPath $errFile) { Get-Content -Raw -LiteralPath $errFile } else { "" }
    throw "codex debug prompt-input produced no output. Exit=$LASTEXITCODE. $stderr"
  }

  $content = Get-Content -Raw -LiteralPath $OutFile
  $checks = [ordered]@{
    AGENTSGuardrail = $content -match "Design Orchestrator Guardrail"
    FirstOpenRule = $content -match "first open and read"
    SkillPath = $content -match "design-auto-orchestrator(?:\\\\|\\|/)SKILL\.md"
    TriggerFrontload = $content -match "design-auto-orchestrator:\s*UI/UX frontend website portfolio"
  }

  $rows = $checks.GetEnumerator() | ForEach-Object {
    [pscustomobject]@{
      Check = $_.Key
      OK = [bool]$_.Value
      Detail = $OutFile
    }
  }
  $rows

  $failed = @($rows | Where-Object { -not $_.OK })
  if ($failed.Count -gt 0) {
    exit 1
  }
} finally {
  if ($removeOutFile) {
    Remove-Item -LiteralPath $OutFile -Force -ErrorAction SilentlyContinue
  }
  Remove-Item -LiteralPath $errFile -Force -ErrorAction SilentlyContinue
}
