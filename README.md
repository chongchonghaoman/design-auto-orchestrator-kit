# Design Auto Orchestrator Kit

一个面向 Codex 的「设计类 Skill 自动编排 + 一键安装」开源套件。

你把这个仓库链接发给 Agent，它可以把本仓库里的总控 Skill 装到本地，并同步安装/拉取它需要调用的设计类 Skill、CLI 工具和参考资源。目标是让 Codex 在做 UI、UX、前端视觉、图标、可访问性、Open Design 相关任务时，不需要你每次手动点名某个 Skill，而是由总控 Skill 在工作过程中自动判断该用什么。

## 它解决什么问题

很多设计类 Skill 单独都很有用，但直接堆在本地会有几个问题：

- 你必须知道每个 Skill 的名字和适用场景。
- 泛用词触发容易混乱，比如 `minimal`、`premium`、`dashboard` 之类。
- 总控 Skill 如果只引用别的 Skill 名字，但用户本地没装，下游调用就会失效。
- 别人拿到你的 Skill 仓库链接后，还要自己一个个找依赖，部署门槛太高。

这个仓库采用「方案 A」：只开源一个轻量总控仓库，不把第三方项目源码直接塞进来；安装时从公开 GitHub 上游拉取所需 Skill 和工具。这样既方便别人部署，也尊重上游项目来源和许可证。

## 会安装什么

安装器会部署本仓库的核心 Skill：

- `design-auto-orchestrator`：面向设计任务的自动路由器，会根据任务类型选择合适的本地 Skill、工具和参考库。

也会安装或校验这些下游 Skill / 工具：

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

这样可以减少全局 Skill 触发噪音，同时在需要时仍然能让总控 Skill 读取精确参考。

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

## 怎么使用

重启 Codex 后，不需要刻意说 Skill 名字，直接用自然语言描述任务：

```text
这个页面 AI 味太重，帮我改得更高级。
做一个 SaaS 后台 dashboard。
重做这个官网首页。
帮我找一个设置图标。
检查这个 UI 的响应式和可访问性问题。
这个本地设计稿用 Open Design 跑一下。
```

`design-auto-orchestrator` 会先判断任务属于哪类设计工作，再选择最小但够用的 Skill / 工具组合。

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

可以直接把这个仓库链接发给 Codex / Agent：

```text
请帮我部署这个 Codex 设计自动编排 Skill：
https://github.com/chongchonghaoman/design-auto-orchestrator-kit

部署完成后运行健康检查，并告诉我哪些 Skill / 工具已经可用。
```
