---
name: design-auto-orchestrator
description: Automatic design-task orchestrator. Use for any UI, UX, frontend, product interface, website, landing page, portfolio, dashboard, admin panel, app screen, component, form, table, navigation, design system, typography, color, layout, motion, icon, accessibility, responsive, screenshot critique, visual polish, anti-AI-slop, Open Design, or design-resource selection task, even when the user does not name a design skill. Routes work to the right local design skills and tools automatically.
---

# Design Auto Orchestrator

This is the first stop for design-adjacent work. Treat vague user language as useful product/design signal, infer the real job, then route to the smallest useful combination of local design skills and tools.

## Core Rule

Do not wait for the user to name a skill. If the request touches interface design, frontend visuals, UX quality, design systems, icons, screenshots, accessibility, layout, motion, or Open Design, classify the task and proceed.

Load only the selected downstream skill files. Do not blindly read every design skill.

## Automatic Intake

Before choosing tools, classify:

- **Surface**: marketing page, portfolio, SaaS app, dashboard, admin, form, table, component, mobile screen, deck/artifact, screenshot review, design-system work.
- **Task mode**: create, redesign, polish, audit, critique, implement, extract, choose style, select icons, generate Open Design artifact.
- **Risk level**: light, medium, heavy.
- **Inputs present**: repo code, screenshots/images, `DESIGN.md`, `PRODUCT.md`, Tailwind/shadcn/design tokens, brand assets, Open Design project.

Prefer acting over asking. Ask one concise question only when two routes would produce materially different outputs.

## Routing

Use [references/routing.md](references/routing.md) for the full routing table when the task is not obvious.

Fast defaults:

- **Need a design system or style recommendation**: run `ui-ux-pro-max` first.
- **SaaS/admin/dashboard/forms/tables/components**: use `ui-design-brain`.
- **Landing page, portfolio, expressive web page, visual redesign**: use `frontend-design`, then `hallmark` or `design-taste-frontend` for anti-slop polish.
- **"Too AI", "not premium", "ugly", "generic", "make it high-end"**: use `hallmark`; add `impeccable` for deeper critique.
- **Review/audit/accessibility/responsive quality**: use `web-design-guidelines`; add `hallmark audit` for visual slop.
- **Icons**: use `better-icons` CLI.
- **Local-first design generation/artifact/project workflow**: verify Open Design daemon, then use `open-design` MCP or `od` CLI.
- **Specific visual style from the 67-style library**: read only that slug under the local source cache `design-skill-sources\awesome-design-skills\skills\<slug>`.
- **Research/strategy/ops/handoff/design-process work**: read only the relevant plugin under the local source cache `design-skill-sources\designer-skills`.

## Workflow Depth

Choose the lowest depth that will satisfy the request:

- **Light**: one skill/tool, no broad scan. Use for icons, small component polish, one review, quick style advice.
- **Medium**: project scan + design system + implementation/polish skill. Use for new pages, dashboards, redesigned screens.
- **Heavy**: project scan + design system + implementation + anti-slop pass + screenshot or guideline audit. Use for user-facing deliverables, homepage redesigns, production UI, or when the user asks for complete, production, deploy, ship, high-end, or audit.

## Project Scan

For existing repos, inspect in parallel where useful:

- `package.json`, framework config, `src/`, `app/`, `pages/`, `components/`
- Tailwind/shadcn/Radix/Material/Fluent/Carbon/Ant/Bootstrap usage
- `DESIGN.md`, `PRODUCT.md`, `README.md`
- CSS variables, theme files, fonts, icon packages
- screenshots or attached images

Preserve existing design systems, routes, tokens, analytics-relevant names, and component boundaries unless the user explicitly asks for a rebuild.

## Tool Commands

Use these deterministic helpers when needed. Resolve Codex home first:

```powershell
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
python (Join-Path $CodexHome "skills\ui-ux-pro-max\scripts\search.py") "<brief>" --design-system -p "<Project>"
better-icons search <query> --limit 10 --json
better-icons get <icon-id>
Invoke-WebRequest -UseBasicParsing http://127.0.0.1:7456/api/health
codex -c 'service_tier="fast"' mcp get open-design
```

Run the bundled health check when the design toolchain itself may be broken:

```powershell
$CodexHome = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $CodexHome "skills\design-auto-orchestrator\scripts\health-check.ps1")
```

## Done Criteria

For design build or redesign tasks, done means:

- The selected design route is clear from the work.
- Code or artifact is actually changed/created when requested.
- Obvious AI-design tropes are removed.
- Mobile/responsive text and controls fit.
- Icons are from a consistent source.
- Accessibility basics are checked for interactive UI.
- A smoke test, screenshot check, lint/build, or relevant health check ran when feasible.

If a downstream tool is unavailable, name the missing piece and continue with the best local fallback.
