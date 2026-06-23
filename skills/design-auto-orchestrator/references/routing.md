# Routing Reference

Use this file only when the best downstream route is not obvious from the user request, project scan, screenshot, implementation context, or validation result.

Do not require exact user wording. Route from observed signals during the work process.

## Creation And Redesign

| Observed signal | First route | Add when needed |
|---|---|---|
| "Give me a design system", "recommend style", "one sentence brief to UI" | `ui-ux-pro-max` | `frontend-design` for web page implementation |
| SaaS dashboard, admin panel, settings, CRM, tables, filters, forms | `ui-design-brain` | `web-design-guidelines` for review |
| Landing page, portfolio, product homepage, marketing site | `frontend-design` | `hallmark`, `design-taste-frontend` |
| Existing UI looks generic, AI-made, ugly, cheap, too templated | `hallmark` | `impeccable` |
| Mobile app screen concept | `open-design` router or existing mobile/imagegen frontend skills | `ui-ux-pro-max` for system |
| 3D or immersive web | existing `threejs` skill | screenshot/canvas validation |

## Audit And Polish

| Observed signal | First route | Add when needed |
|---|---|---|
| Accessibility, responsive, interface guideline review | `web-design-guidelines` | Playwright/screenshot checks |
| Visual critique of screenshot | `hallmark study` or visual critique source library | `impeccable` |
| Production hardening of UI states | `ui-design-brain` | `web-design-guidelines` |
| "Make it more premium/high-end" | `hallmark` | `frontend-design` if rebuilding |

## Resource Selection

| Need | Route |
|---|---|
| Icons | `better-icons` CLI |
| Specific style such as brutalism, bento, riso, glassmorphism | source cache: `awesome-design-skills\skills\<slug>` |
| UX research, strategy, handoff, design ops | source cache: `designer-skills\<plugin>` |
| Open Design local artifact generation | health-check daemon, then `open-design` MCP or `od` CLI |

## Depth Selection

Light:

- Single component tweak
- Icon search
- Quick critique
- Small copy/label fix

Medium:

- New page/screen
- Dashboard or admin UI
- Existing page redesign inside current codebase
- Need design system recommendation

Heavy:

- User says complete, production, deploy, ship, high-end, audit
- Homepage/portfolio/key user-facing surface
- Multiple routes/components
- Needs screenshot/browser validation

## Escalation Rules

- If a route chooses `ui-ux-pro-max`, run its search script before designing unless the user already provided a locked `DESIGN.md`.
- If a route chooses `hallmark`, preserve codebase boundaries and read its required reference file for the verb used.
- If a route chooses `web-design-guidelines`, fetch the latest Vercel guideline source when doing an actual review.
- If a route chooses Open Design, check `http://127.0.0.1:7456/api/health` first. If down, start `od --no-open`.
- If a large collection is needed, read one concrete skill or plugin folder only. Do not bulk-load the entire collection.
