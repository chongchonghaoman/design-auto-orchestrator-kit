# Design Auto Orchestrator Kit

一个面向 Codex 的「设计类 Skill 自动编排 + 一键安装」开源套件。

它的目标不是让用户多记一个 Skill 名字，也不是让用户学会某种调用方法。安装后，它应该变成 Agent 的后台判断层：用户照常提出产品、前端、页面、组件、图标、体验、视觉、响应式、可访问性等任务，Agent 在执行过程中自动判断当前步骤是否需要设计类 Skill / 工具，并按需加载。

## 核心原则：用户不调用，Agent 自己判断

这个仓库的设计初衷是：

- 用户不需要说 `design-auto-orchestrator`。
- 用户不需要说 `ui-ux-pro-max`、`hallmark`、`better-icons`、`Open Design` 等下游名字。
- 用户不需要描述“请调用某某 Skill”。
- Agent 应该根据任务语义、项目代码、截图、设计稿、当前实现步骤和验证结果，自动判断该用哪些设计工具。
- 自动判断不只发生在任务开头，也应该发生在工作过程中的子步骤里。

理想流程是：

1. 用户正常交代任务。
2. Agent 读取需求、扫描项目、查看截图或修改代码。
3. 只要发现 UI / UX / frontend / visual polish / icon / accessibility / responsive / Open Design 相关子任务，就自动进入设计编排流程。
4. 编排器选择最小但够用的下游 Skill / 工具组合。
5. Agent 回到原任务继续实现、验证和交付。

用户感知到的应该是「Agent 变聪明了」，而不是「我又多了一个要手动点名的工具」。

## 它解决什么问题

很多设计类 Skill 单独都很有用，但直接堆在本地会有几个问题：

- 用户必须知道每个 Skill 的名字和适用场景。
- 泛用词触发容易混乱，比如 `minimal`、`premium`、`dashboard` 之类。
- 总控 Skill 如果只引用别的 Skill 名字，但用户本地没装，下游调用就会失效。
- 别人拿到你的 Skill 仓库链接后，还要自己一个个找依赖，部署门槛太高。

这个仓库采用「方案 A」：只开源一个轻量总控仓库，不把第三方项目源码直接塞进来；安装时从公开 GitHub 上游拉取所需 Skill 和工具。这样既方便别人部署，也尊重上游项目来源和许可证。

## 会安装什么

安装器会部署本仓库的核心 Skill：

- `design-auto-orchestrator`：设计任务后台编排器，负责根据任务和执行过程中的信号自动选择本地 Skill、工具和参考库。

也会安装或校验这些下游 Skill / 工具：

- `$HOME\.codex\AGENTS.md` 中的 Design Orchestrator Guardrail，用来把自动编排规则放到更靠前的常驻说明层。
- `ui-ux-pro-max`
- `hallmark`
- `better-icons`
- `ui-design-brain`
- `web-design-guidelines`
- `frontend-design`
- `design-taste-frontend`
- `impeccable`
- `better-icons` CLI
- 可选：Open Design 源码缓存、`od` CLI、本地 daemon、Codex MCP 配置

大型参考库不会全部注册成全局 Skill，而是克隆到本地 source cache：

- `awesome-design-skills`
- `designer-skills`

这样可以减少全局 Skill 触发噪音，同时在需要时仍然能让编排器读取精确参考。

## 快速安装

在 PowerShell 中运行：

```powershell
git clone https://github.com/chongchonghaoman/design-auto-orchestrator-kit.git
cd design-auto-orchestrator-kit
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

安装完成后，重启 Codex。

## 常用参数

```powershell
# 强制重装/更新已有 Skill 文件夹
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1 -Force

# 跳过较重的 Open Design 本地构建
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1 -SkipOpenDesign

# 使用自定义 Codex Home
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install.ps1 -CodexHome "D:\.codex"
```

## 健康检查

安装后可以运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME\.codex\skills\design-auto-orchestrator\scripts\health-check.ps1"
```

如果安装时用了 `-SkipOpenDesign`，健康检查也传入同样参数：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME\.codex\skills\design-auto-orchestrator\scripts\health-check.ps1" -SkipOpenDesign
```

## 安装后怎么生效

正常向 Codex 提任务即可。不要为了触发它而刻意写 Skill 名字，也不要把工具名当成口令。

安装器会做两层配置：

- `AGENTS.md` 守门规则：新会话开始时就能看到，要求设计/前端/UI 相关任务先读取总控 Skill。
- `design-auto-orchestrator` Skill：负责真正分类任务，并选择下游 Skill / 工具。

只把规则写在 Skill 里不够稳，因为 Skill 内容只有在被选中后才会被读取；`AGENTS.md` 守门规则用来减少这种漏触发。

比如当任务涉及这些内容时，Agent 应该自行介入设计编排：

- 页面、官网、落地页、作品集、后台、dashboard、表单、表格、导航、组件。
- 视觉不够高级、AI 味重、模板感强、布局松散、字体/颜色/间距不对。
- 图标选择、设计系统、品牌风格、动效、响应式、可访问性、截图审查。
- 现有前端项目里的 UI 实现、重构、打磨、上线前检查。

如果某个 Agent 不支持本地 `SKILL.md` 自动发现，那么这个仓库只能完成安装，不能强行让那个 Agent 具备自动路由能力。Codex 支持通过 Skill 描述进行自动匹配，因此这个套件主要面向 Codex 本地环境。

## 重要说明

- 本仓库不是第三方 Skill 的搬运合集，不直接 vendoring 上游源码。
- 安装器会在安装时从公开 GitHub 上游下载对应 Skill 文件夹或源码。
- Open Design 比纯 Skill 安装更重，安装器会在本机具备 Node 24 和 pnpm 时尝试配置。
- 新 Skill 安装后，需要重启 Codex 才能在会话里被识别。
- 如果上游项目结构发生变化，安装器可能需要同步更新。

## 上游项目

这个套件是安装器和总控路由器，安装时会依赖以下上游项目：

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

每个上游项目仍归原作者所有，并受各自许可证约束。本仓库通过公开 GitHub 来源下载它们，方便用户自行检查、更新和追踪原项目。

## 推荐转发方式

可以直接把这个仓库链接发给 Codex / Agent，让它部署到本地：

```text
请帮我把这个 GitHub 仓库部署到本地 Codex 环境：
https://github.com/chongchonghaoman/design-auto-orchestrator-kit

部署完成后运行健康检查。后续我不会手动点名任何设计 Skill，请确认本地 Skill 描述支持按任务语义和执行步骤自动选择工具。
```
