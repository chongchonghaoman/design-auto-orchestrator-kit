# Design Auto Orchestrator Kit

One-command installer for a Codex design-task router plus the downstream design skills it uses.

## What It Installs

The installer deploys this local skill:

- `design-auto-orchestrator`: broad automatic router for UI, UX, frontend, visual polish, accessibility, icons, and Open Design tasks.

It also installs or verifies these downstream skills/tools:

- `ui-ux-pro-max`
- `hallmark`
- `better-icons`
- `ui-design-brain`
- `web-design-guidelines`
- `frontend-design`
- `design-taste-frontend`
- `impeccable`
- `better-icons` CLI
- optional Open Design source cache, `od` CLI, daemon, and Codex MCP config

Large reference libraries are cloned into a source cache instead of bulk-installed as global skills:

- `awesome-design-skills`
- `designer-skills`

This avoids noisy global triggers such as `minimal`, `premium`, and `dashboard`, while still letting the orchestrator read exact references when needed.

## Quick Install

From PowerShell:

```powershell
git clone https://github.com/YOUR_NAME/design-auto-orchestrator-kit.git
cd design-auto-orchestrator-kit
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

Then restart Codex.

## Common Options

```powershell
# Reinstall/update existing skill folders
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1 -Force

# Skip the heavier Open Design local build
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1 -SkipOpenDesign

# Use a custom Codex home
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1 -CodexHome "D:\.codex"
```

## Health Check

After install:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME\.codex\skills\design-auto-orchestrator\scripts\health-check.ps1"
```

If you installed with `-SkipOpenDesign`, pass that to the health check too:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME\.codex\skills\design-auto-orchestrator\scripts\health-check.ps1" -SkipOpenDesign
```

## How To Use

After restarting Codex, ask naturally:

```text
This page looks too AI-generated. Make it feel premium.
Build me a SaaS dashboard.
Redesign this homepage.
Find a settings icon.
Audit this UI for accessibility and responsive issues.
Use Open Design for this local artifact.
```

The router classifies the task and chooses the smallest useful combination of local skills and tools.

## Notes

- This repository does not vendor third-party skill source code. The installer downloads public upstream skill folders at install time.
- Open Design is heavier than the pure skill installs. The installer attempts it when the local environment has Node 24 and pnpm.
- Codex must be restarted after new skills are installed.

## Upstream Projects

This kit is an installer and router. It depends on these upstream projects at install time:

- [UI UX Pro Max](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill)
- [Hallmark](https://github.com/Nutlope/hallmark)
- [Better Icons](https://github.com/better-auth/better-icons)
- [UI Design Brain](https://github.com/carmahhawwari/ui-design-brain)
- [Vercel Agent Skills](https://github.com/vercel-labs/agent-skills)
- [Anthropic Skills](https://github.com/anthropics/skills)
- [Taste Skill](https://github.com/Leonxlnx/taste-skill)
- [Impeccable](https://github.com/pbakaus/impeccable)
- [Open Design](https://github.com/nexu-io/open-design)
- [Awesome Design Skills](https://github.com/bergside/awesome-design-skills)
- [Designer Skills](https://github.com/Owl-Listener/designer-skills)

Each upstream project remains owned by its authors and is governed by its own license. This repository downloads them from their public GitHub sources so users can update or inspect the original projects directly.
