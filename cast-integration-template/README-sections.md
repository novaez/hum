# cast 集成时要追加/合并到 README.md 的内容

> 这份文件是 **cast 安装器**集成到 hum vault 时要 append（或 splice）进 `README.md` 的模板内容。
> cast installer 应在 `<!-- BEGIN cast-integration -->` 和 `<!-- END cast-integration -->` 之间写入（支持幂等重跑）。

---

## 锚点 me ⚓

在 hum 的三层（捕获 / 积累 / 创作）之上，Current 带来一个锚点 **me ⚓**——使命、身份、信念、能力，所有流动从这里出发。

| 文件夹 | 用途 | 内容举例 |
|--------|------|---------|
| `00 Me ⚓` | 自我档案，Obsidian 与 Current 的桥 | `who-am-i.md`（身份）、`mission.md`（使命愿景）、`values.md`（信念价值观）、`how-i-work/`（能力流程）、`my-lessons/`（自我教练反思）、`ahoy-private/`（Ahoy! 观察档案） |

**me 不只是给自己看**：Current 体系（cast / Ahoy!）每次启动时都会读取 `me/`，让 AI 系统以"你的视角"工作。`me/` 目录结构由 Current 2.0 约定，位置通过 `~/Current/.config/cast.config.json` 的 `me_dir` 指向 `00 Me ⚓`。

**me 和 Garden 的关系**：Garden 是"工作室"——自由思考、持续生长；me 是"出版物"——结构化、稳定、给系统读。Garden 里成熟的自我理解提炼到 me；me 里的内容也会因深入反思而扩展回 Garden。两者通过 Obsidian 双向链接互相引用。

## 两条对称的提炼流（Current 扩展版）

装了 Current 之后，系统里出现一对"**随手记一手原料、有价值再结构化提炼**"的对称——外部知识和内在自我都走这个模式：

| | 原料层（捕获） | 提炼层（有模板） |
|---|---|---|
| **外部世界** | `10 Inbox 📥`（随手扔） | `20 Wiki 📖`（LLM `/compile` 编译） |
| **内在自我** | `11 Journal 📓`（随手记） | `00 Me ⚓/my-lessons`（亲手提炼） |

**Journal → my-lessons = Inbox → Wiki 的自我层版本。**

## Obsidian 30 Projects 和 Current projects 的分工

- **Obsidian 30 Projects**：项目的**个人设计室**。一个人的思考、设计、权衡、不成熟的探索。快速迭代，不用 commit push。
- **Current projects**：项目的**团队工作台**（`~/Current/projects/<slug>/`）。对外的 brief、progress、decisions，git push 到共享 repo 给团队。

流动：思考在 Obsidian → 成熟后落到 Current → 执行中的新思考可再回流 Obsidian 反思。

## Session 搭配

**总控台 + 专注位** 模式：

- **总控台（常驻）**：me session，通过 `current` 命令启动
  - 早上开机——cast 报告状态、给建议
  - 定今天主要做什么
  - 晚上回来收尾、写反思
- **专注位（按任务开 1-2 个）**：
  - 构思/设计：Obsidian vault 里启动 agent
  - 写代码：`cd ~/your-projects/<project> && claude`
  - 整理 Inbox：Obsidian vault 里跑 `/compile`
  - 推进具体 current 项目：`cd ~/Current/projects/<slug> && claude`

**平均并行数 2-3 个**。5+ 个就是警告信号——说明在切得太碎。

## Current 工作场景

| 你要做什么 | 去哪里 |
|-----------|--------|
| 日常团队协作（写进展、管项目）| `cast`（`current` 命令启动）|
| 拿全局洞察（团队状态、待办、课题）| `Ahoy!`（cast 的读取模式）|
| 团队共享的项目推进 | `~/Current/projects/<slug>/` 的项目 repo |

## Current 工作流

| 操作 | 说明 |
|------|------|
| `current` | 启动 Current 体系（cast），以 `me/` 为锚点加载工作上下文 |

## Current 关键习惯

- **session 之间通过文件系统通信**——不要复制粘贴跨 session。项目 push 了代码，me session 下次启动自动看到 git log。
- **me session 是唯一常驻**——它是一天的叙事线。如果自己也跑偏了，果断 `/clear` 回到总控台状态。

## Current 命名规范（me 子结构）

- `who-am-i.md` / `mission.md` / `values.md` / `how-i-work/` / `my-lessons/` / `my-teams.md` / `ahoy-private/`（Current 2.0 约定结构，不要改名）
