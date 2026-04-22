# cast 集成时要追加/合并到 AGENTS.md 的内容

> 这份文件是 **cast 安装器**集成到 hum vault 时要 append（或 splice）进 `AGENTS.md` 的模板内容。
> cast installer 应在 `<!-- BEGIN cast-integration -->` 和 `<!-- END cast-integration -->` 之间写入（支持幂等重跑）。

---

## 00 Me ⚓ 锚点

`00 Me ⚓/` 是我的自我档案，被 Current 体系（cast / Ahoy!）通过 `~/Current/.config/cast.config.json` 的 `me_dir` 读取。**仅本地，不推到任何 remote**。

子结构（Current 2.0 约定，不要改名）：

- `who-am-i.md`（身份）
- `mission.md`（使命愿景）
- `values.md`（信念价值观）
- `how-i-work/`（能力·流程，含 `reflection-rhythm.md` 等行为指引）
- `my-lessons/`（自我反思日志，四段式：触发 / 原视角 / 新视角 / 调整）
- `ahoy-private/`（Ahoy! 观察档案，本地私有）
- `my-teams.md`（所属团队列表，solo 用户留空即可）

### 关系

- **Garden 🌱 vs my-lessons**：Garden 是"工作室"（自由生长、不限体裁）；my-lessons 是"出版物"（结构化反思日志）
- **Journal 📓 vs my-lessons**：Journal 是原料（随手记），my-lessons 是按模板提炼的成品
- **Journal → my-lessons = Inbox → Wiki 的自我层版本**（原料→提炼的对称模式）

### 被 AI 读取的含义

me 里的 markdown 文件是"自然语言编程"——我写下希望 AI 怎么伺候自己，AI 按此行事。启动 cast 或任何 session 时，AI 会加载 me 全部内容并按其中的偏好工作。典型例子：`how-i-work/reflection-rhythm.md` 描述了我希望 AI 在一天中什么时刻、以什么方式推动我反思。

## my-lessons 录入规范

`00 Me ⚓/my-lessons/` 是我个人自我反思的结构化日志。

- 命名格式：`YYYY-MM-主题.md`（主题简短描述）
- 模板见 `my-lessons/README.md`（触发 / 原视角 / 新视角 / 调整）
- **不要每天都逼出一条 lesson**——lesson 是"换视角"的偶尔时刻；日常反思写 Journal
- 写完提醒我，link 回相关 Journal / Wiki / Garden 条目
