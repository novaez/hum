# Installing hum L2 推荐插件 — guide for AI agents

> 如果你是 AI agent 在帮用户装 hum 的推荐插件（L2），按本文档执行。
> **前提**：用户已装完 L1（当前目录是个 hum vault，有 AGENTS.md 和 `.claude/commands/compile.md`）。

## 你要做的事

1. 确认前提（在 hum vault 里）
2. 问用户要装哪些
3. 程序化下载 + 铺文件
4. 写 `.obsidian/community-plugins.json`
5. 验证 + 告诉用户在 Obsidian 里激活 community plugins

## 1. 确认前提

```bash
ls AGENTS.md .claude/commands/compile.md >/dev/null 2>&1 \
  || { echo "✗ 不在 hum vault；先装 L1"; exit 1; }
```

## 2. 推荐插件清单

| Plugin ID | GitHub Repo | 用途 | 在注册表 | 推荐度 |
|---|---|---|---|---|
| `obsidian-outliner` | `vslinko/obsidian-outliner` | 列表大纲操作（Tab 缩进、拖动） | ✓ | ★★★ |
| `table-editor-obsidian` | `tgrosinger/advanced-tables-obsidian` | 表格编辑体验升级 | ✓ | ★★★ |
| `claudian` | `YishenTu/claudian` | 在 Obsidian 里内嵌 Claude Code / Codex 做 AI 协作 | ✗（beta，但有标准 release assets） | ★★★ |
| `obsidian-zoom` | `vslinko/obsidian-zoom` | Zoom 到 heading 专注 | ✓ | ★★ |
| `pdf-plus` | `RyotaUshio/obsidian-pdf-plus` | PDF 高亮/批注/引用 | ✓ | ★★ |
| `marp` | `JichouP/obsidian-marp-plugin` | Markdown 做 PPT | ✓ | ★ |

**问用户**："全装、只装核心 3 个（Outliner + Advanced Tables + Claudian）、还是挑着装？"

> **关于 Claudian**：它是 beta 插件，没进官方注册表，但 GitHub release 有标准的 `main.js / manifest.json / styles.css`，装法跟其他插件完全一样——直接 download 就行，**不依赖 BRAT**。

## 3. 下载 + 铺文件

bash 函数：

```bash
install_plugin() {
  local PLUGIN_ID=$1
  local REPO=$2
  local DIR=".obsidian/plugins/$PLUGIN_ID"

  mkdir -p "$DIR"

  # 必需文件（main.js 和 manifest.json 是所有插件都有的）
  curl -fsSL "https://github.com/$REPO/releases/latest/download/main.js" -o "$DIR/main.js" \
    || { echo "✗ $PLUGIN_ID: main.js 下载失败"; return 1; }
  curl -fsSL "https://github.com/$REPO/releases/latest/download/manifest.json" -o "$DIR/manifest.json" \
    || { echo "✗ $PLUGIN_ID: manifest.json 下载失败"; return 1; }

  # 可选 styles.css（不是所有插件都有；失败就删除空文件）
  curl -fsSL "https://github.com/$REPO/releases/latest/download/styles.css" -o "$DIR/styles.css" 2>/dev/null \
    || rm -f "$DIR/styles.css"

  echo "✓ $PLUGIN_ID"
}
```

按用户选的调用：

```bash
install_plugin "obsidian-outliner" "vslinko/obsidian-outliner"
install_plugin "table-editor-obsidian" "tgrosinger/advanced-tables-obsidian"
install_plugin "claudian" "YishenTu/claudian"
# 按需再加 obsidian-zoom / pdf-plus / marp
```

## 4. 写 community-plugins.json

**把用户选中的 plugin ID 全写进去**（只列选的，不要照抄示例）。用 jq 或手写 JSON 都行。简单写法：

```bash
# 例：用户选了 outliner + table-editor + claudian
cat > .obsidian/community-plugins.json << 'EOF'
[
  "obsidian-outliner",
  "table-editor-obsidian",
  "claudian"
]
EOF
```

## 5. 验证

```bash
# 每个装的插件目录里都应有 main.js + manifest.json
ls .obsidian/plugins/*/manifest.json

# community-plugins.json 列对
cat .obsidian/community-plugins.json
```

## 6. 告诉用户

1. 如果 Obsidian 已经开着这个 vault → `Cmd+R` 重载
2. **首次装社区插件**：Obsidian 设置 → Community plugins → 有个"Turn on community plugins"开关，打开
3. 进 Community plugins 列表，确认你选的每个插件是 **Enabled**（绿色 toggle）；如果是 Installed 但灰色，点一下启用
4. 启用后插件效果立即生效（不用重启）

## 7. 浏览器扩展推荐（手动装，AI 不代劳）

**Obsidian Web Clipper** 是浏览器扩展（Chrome / Firefox / Safari），不是 Obsidian 插件，AI 没法脚本装。告诉用户：

> 推荐装 [Obsidian Web Clipper](https://obsidian.md/clipper)——浏览网页时一键存入 Inbox，比复制粘贴顺得多。装完在扩展里把默认 vault 指向你的 hum vault，Clip 目标目录选 `10 Inbox 📥/`。

扩展地址：

- [Obsidian 官方介绍](https://obsidian.md/clipper)
- Chrome Web Store / Firefox Add-ons / Safari Extensions 搜 "Obsidian Web Clipper"

## 失败速查

| 症状 | 原因 | 处理 |
|---|---|---|
| `curl 404` on `main.js` | release 没这个文件（个别插件会把主文件放别处） | 去 `https://github.com/<repo>/releases/latest` 看 assets 实际文件名 |
| 装完 Obsidian 不显示插件 | "Community plugins" 没打开 | Settings → Community plugins → Turn on |
| 显示但用不了 | 插件要求的 minAppVersion 比 Obsidian 高 | 升级 Obsidian 或装旧版插件 |
| `latest/download` 返回的不是文件而是 HTML | 该 repo 没 release，只有 source code | 不推荐装这种插件；去 GitHub 看是否改用 release 分发 |
