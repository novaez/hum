# Installing hum — guide for AI agents

> 如果你是 AI agent（Claude / Cursor / Gemini / Codex 等）在帮用户装 hum，请按本文档一步步执行。用户大概率没装过 hum，可能也没装 Obsidian 或 Claude Code。你的任务：把所有环节打通，装完能跑。

## 你要做的事（总览）

1. 环境检查 → 缺什么引导用户装
2. 问用户 vault 名字和位置
3. 建 vault 目录
4. 跑 `install.sh` 铺骨架
5. 验证铺对了
6. 引导用户第一次使用

## 1. 环境检查

### macOS 验证

```bash
uname
```

期望输出 `Darwin`。不是的话停下来告诉用户："hum 目前只支持 macOS（sed 写法是 BSD 版本）。装不了。"

### Obsidian

```bash
ls /Applications/Obsidian.app 2>/dev/null && echo "installed" || echo "missing"
```

- `installed`：继续
- `missing`：停下来，告诉用户"请从 https://obsidian.md 下载 Obsidian 并安装，装完告诉我继续"

### Claude Code

```bash
which claude
```

- 有输出（路径）：继续
- 无：停下来告诉用户"请按 https://claude.com/claude-code 装 Claude Code 并登录，装完告诉我继续"

## 2. 问用户偏好

一次性问，不要拆开：

- **vault 名字**？（会变成文件夹名，比如 `brain` / `thinking` / 你的昵称）
- **放哪个目录下**？默认 `~/Documents`，用户可改

## 3. 建 vault 目录

```bash
mkdir -p "<path>/<vault_name>"
cd "<path>/<vault_name>"
```

**注意**：如果目录已存在且非空（不只有 `.DS_Store`），停下来问用户"这里已经有文件，在这建还是换个地方？"，别默默覆盖。

## 4. 铺骨架

```bash
curl -fsSL https://cdn.jsdelivr.net/gh/novaez/hum@main/install.sh | sh
```

预期输出末尾有 `✓ hum 骨架已铺到当前目录` 和「接下来」几行提示。

如果报错，常见：

- 网络不通：先 `curl -I https://cdn.jsdelivr.net` 确认
- 目录冲突：install.sh 检测到已有 `README.md` / `AGENTS.md` 会 abort；之前跑过的话先清空再重跑

## 5. 验证

```bash
# 6 个目录
ls -d "10 Inbox 📥" "11 Journal 📓" "20 Wiki 📖" "21 Garden 🌱" "30 Projects 🎯" "31 Areas 🔄"

# 核心文件 + symlink
ls AGENTS.md README.md
ls -la CLAUDE.md GEMINI.md   # 应该是 → AGENTS.md 的 symlink

# skill
ls .claude/commands/compile.md .claude/commands/lint.md

# README 占位符已替换
grep -c "{{VAULT_NAME}}" README.md   # 期望 0
head -1 README.md                    # 期望 "# <vault 名>"
```

任何一项失败，把具体错误贴给用户问要不要重试。

## 6. 引导第一次使用

告诉用户：

1. 在 Obsidian 里打开 vault：启动 Obsidian → `File → Open vault` → 选刚建的目录
2. 往 `10 Inbox 📥/` 扔 2-3 篇你关注的文章（Obsidian 里新建 `.md` 粘贴全文，或塞 URL 让 Claude 抓）
3. 终端 `cd` 到 vault，跑 `claude` 启动会话
4. 让 Claude 跑 `/compile` 把 Inbox 编译成 Wiki 条目
5. 问 Claude："最近有什么新信息？"

## 7. 主动询问：要不要接着装 L2 / L3 增强？

L1 已经可用。但还有 3 个可选增强，**主动问用户想装哪些**（一次性列清，让他挑，不要拆开问）：

| 层 | 做什么 | 自动化程度 | 用户需做的 | 约耗时 |
|---|---|---|---|---|
| **L2 推荐插件** | Outliner / Advanced Tables 等提升编辑体验 | ~95% | 最后点一下 "Turn on community plugins" | 3 分钟 |
| **L3 图床** | 粘贴截图自动上传到 GitHub public repo + jsdelivr CDN | ~90% | 首次启动 PicList 过 Gatekeeper；装 PicList 可能要 sudo 密码 | 10 分钟 |
| **L3 大文件备份** | PDF / PPT 自动 git push 到 private repo | ~85% | Finder 右键绑定 Folder Action（3 次点击）；授权 Full Disk Access | 15 分钟 |

**隐私提示**（提 L3 图床时一并说）：
> L3 图床会把图片传到 **public GitHub repo**，全世界可访问（URL 不公开传播但理论上可爬取）。涉密/涉私截图不要贴。

**问用户**："要接着装哪些？可选项：全要 / 只要 X / 只要 X+Y / 都跳过 / 过会再说。"

### 根据选择续装

按用户选的，**依次** fetch 对应文档并执行里面的步骤：

- L2：`https://cdn.jsdelivr.net/gh/novaez/hum@main/INSTALL-AI-L2-plugins.md`
- L3 图床：`https://cdn.jsdelivr.net/gh/novaez/hum@main/INSTALL-AI-L3-image-host.md`
- L3 大文件备份：`https://cdn.jsdelivr.net/gh/novaez/hum@main/INSTALL-AI-L3-large-file-backup.md`

每一份 fetch 后按里面的流程走到底，走完再问要不要开始下一个。**不要并行**——一份装完再开下一份，方便失败诊断。

### 全部装完 / 用户跳过时

告诉用户：

- hum 可以跟 **cast**（个人身份锚点系统）配合，给你更"知道你是谁"的 AI 协作。cast 还在开发中，稳定后再告诉你怎么装。
- 中途跳过的 L2/L3 以后随时可以装——对 AI 说"按 `<对应 URL>` 装 X"就行。URL 在 hum README 底部有列。

## 失败模式速查

| 症状 | 原因 | 处理 |
|---|---|---|
| `curl: (22) ... 404` | `novaez/hum` 还没建或路径错 | 检查 `https://github.com/novaez/hum` 是否存在 |
| `sed: 1: "...": invalid command` | 不是 macOS（GNU sed vs BSD sed 差异） | hum 暂只支持 macOS |
| `ln: CLAUDE.md: File exists` | 目录冲突 | install.sh 的冲突检测应该先拦住；如果跑到这步说明 bug，汇报给用户 |
| Obsidian 打开 vault 看不到 `.txt` 等文件 | Obsidian 默认不显示未知扩展名 | Settings → Files and links → "Detect all file extensions" 打开 |

## 执行原则

- **做事前先说**：跑每个关键命令前告诉用户你要干嘛，别闷头执行
- **失败就停**：任何 step 报错停下来告诉用户，别自己往后猜
- **不代做决定**：涉及用户偏好（名字、路径）让用户回答，别自作主张
