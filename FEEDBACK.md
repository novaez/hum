# hum Feedback Log

第一手用户反馈归档。按时间倒序。

---

## 2026-04-24 · 第 1 位朋友

**路径**：方式 A（对 AI 说 "按 INSTALL-AI.md 装 hum"）

**摩擦**：0——一条龙跑通，无卡壳

**增强建议**（朋友 + liushu 讨论后）：

1. **Obsidian Web Clipper（浏览器扩展）**
   - 为什么想要：扔网页文章进 Inbox 是核心动作之一，复制粘贴全文比较繁琐；Clipper 一键抓取 + 自动入 Inbox 会顺很多
   - 处理：AI 没法脚本装浏览器扩展，在 L2 doc / skeleton README 加"浏览器扩展推荐"段，附官方链接 + 指引把默认目录设成 `10 Inbox 📥/`
   - 已落实：INSTALL-AI-L2-plugins.md §7 + skeleton/README.md 「浏览器扩展推荐」段
2. **Claudian 插件（Obsidian 里内嵌 Claude Code）**
   - 为什么想要：liushu 自己常用，想推给朋友；在 Obsidian 里直接调 Claude 做 inline edit / slash commands，体验比切终端顺
   - GitHub: `YishenTu/claudian`（beta 插件，不在 Community Plugins 注册表，但 release 有标准 assets）
   - 处理：L2 直接 download 安装，跟其他插件一样的 install_plugin 函数能搞定，**不用 BRAT**
   - 已落实：INSTALL-AI-L2-plugins.md 推荐清单加 Claudian + skeleton/README.md 新增「AI 协作」分组
3. **BRAT（beta 插件管理器）**
   - 原本 liushu 以为装 Claudian 要 BRAT，所以想打包进去
   - 查了 Claudian 的 release 结构，**发现不需要 BRAT 也能装**（只影响后续自动更新 beta 版，不影响首装）
   - 决定：不加 BRAT 到 L2。省一个插件，朋友少一层概念负担

**没记录的行为观察**（因为 0 摩擦就没观察到）：
- 朋友读 README 的哪节停下？——未知
- 第一次 `/compile` 前朋友做了什么？——未知
- 开聊时问 Claude 的第一个问题？——未知

下次陪装时补上这些行为数据。

### L2 + L3 图床继续（同日）

朋友继续从 L2 跑到 L3 图床：

**L2**（推荐插件 AI 代劳）：0 摩擦跑通

**L3 图床**（AI 代劳）：跑通**但踩坑**——
- **摩擦**：AI / 朋友漏了"把 GitHub 设为默认图床"这一步。PicList 默认的 picbed 是 smms；我们的 Python 脚本写了 `picBed.current = 'github'` 到 data.json，但 **PicList 启动后可能用 GUI 缓存覆盖了 data.json 的值**——结果朋友粘贴截图时没上传到 GitHub
- **修复**：`INSTALL-AI-L3-image-host.md` 第 6 步加强：
  1. 重启 PicList 后**必须** GUI 确认 "GitHub 是默认图床"
  2. 不是的话手动点"设为默认"
  3. 失败速查表加一条"粘贴后 URL 不是 jsdelivr"的诊断
- **为什么值得固化**：这是"脚本写了也不保证生效"的典型坑。JSON 合并之后的 UI 应用验证不能省
- **根因深挖（TODO）**：找出 PicList 到底在什么条件下会忽略 data.json 的 `picBed.current`——可能是进程没真正退干净、或有另一个 state 文件、或启动时序问题。以后有时间查一下 PicList 源码
