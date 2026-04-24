# Installing hum L3 图床 — guide for AI agents

> 如果你是 AI agent 在帮用户装 hum 的图床（L3）。
> **前提**：用户已装 L1；在 hum vault 目录；macOS；愿意把图片放进一个 **public** GitHub repo（jsdelivr 只服务 public repo）。
> **效果**：在 Obsidian 里粘贴截图 → 自动上传到 GitHub → markdown 里插入 jsdelivr CDN URL。

## 隐私提示（先说清楚）

**图片进 public GitHub repo 后全世界可访问**（虽然 URL 不主动公开，但理论上可爬取）。如果用户有保密需求（聊天截图、身份证、公司内部界面），**不要装这个**——告诉用户以后有私密方案再来。

## 你要做的事

PicList 的配置文件是 JSON，可以脚本全改——AI 基本能一条龙到底。用户只需要第一次打开 PicList 过一下 macOS Gatekeeper。

1. 前提 + 问偏好
2. 装 PicList（`brew install --cask piclist`）
3. 首次启动让 macOS 接受（GUI：一次点击）
4. 建 GitHub public repo（API）
5. 写 PicList data.json（脚本）
6. 重启 PicList 让配置生效
7. 装 `obsidian-image-auto-upload-plugin` + 写 plugin data.json
8. 告诉用户在 Obsidian 里开启 community plugins（如果还没开）
9. 验证（粘贴截图 → 看 URL）

## 1. 前提 + 问偏好

```bash
ls AGENTS.md >/dev/null 2>&1 || { echo "✗ 不在 hum vault"; exit 1; }
[ "$(uname)" = "Darwin" ] || { echo "✗ 仅支持 macOS"; exit 1; }
```

问用户：

- **GitHub 用户名**
- **GitHub PAT**（带 `repo` scope；不留 shell history：`read -s -p "PAT: " PAT; echo`）
- **图床 repo 叫什么名字**？默认 `my-imgs`
- **隐私确认**：你知道这个 repo 是 public 吗？

## 2. 装 PicList

```bash
# 检查是否已装
ls /Applications/PicList.app 2>/dev/null && echo "已装 PicList" \
  || brew install --cask piclist
```

可能要用户输入 sudo 密码（Homebrew cask 首装）。

## 3. 首次启动 + Gatekeeper

```bash
open -a PicList
```

告诉用户：

- macOS 第一次打开第三方 app 会弹 "Are you sure you want to open it?" 对话框，点"Open"
- PicList 主界面出现后就可以了，**现在先把 PicList 完全退出**（右键菜单栏图标 → Quit），因为下一步要直接改它的配置文件，要它没运行
- 等用户确认 "PicList 退出了" 再继续

## 4. 建 GitHub public repo

```bash
REPO_NAME="my-imgs"  # 或用户自选
curl -sL -X POST \
  -H "Authorization: Bearer $PAT" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/user/repos \
  -d "{\"name\":\"$REPO_NAME\",\"private\":false,\"auto_init\":true}" \
  | grep -q '"full_name"' && echo "✓ repo 建好" \
  || echo "✗ repo 建失败（可能同名已存在，或 PAT 没 repo scope）"
```

## 5. 写 PicList data.json

用 Python 做 JSON 合并（避免覆盖用户已有配置）：

```bash
python3 << PYEOF
import json, os, sys
cfg = os.path.expanduser('~/Library/Application Support/piclist/data.json')

try:
    d = json.load(open(cfg))
except FileNotFoundError:
    d = {}

USER = os.environ['GITHUB_USER']
REPO = os.environ['REPO_NAME']
PAT  = os.environ['PAT']

d.setdefault('picBed', {})
d['picBed']['current'] = 'github'
d['picBed']['github'] = {
    '_configName': 'GitHub Image Bed',
    'repo': f'{USER}/{REPO}',
    'branch': 'main',
    'token': PAT,
    'path': '',
    'webPath': '',
    'customUrl': f'https://cdn.jsdelivr.net/gh/{USER}/{REPO}@main',
}

d.setdefault('settings', {})
d['settings'].setdefault('server', {})
d['settings']['server']['enable'] = True
d['settings']['server'].setdefault('port', 36677)
d['settings']['server'].setdefault('host', '0.0.0.0')

json.dump(d, open(cfg, 'w'), indent=2, ensure_ascii=False)
print('✓ PicList data.json 更新')
PYEOF
```

**注意**：跑这一段前要把 `PAT`、`GITHUB_USER`、`REPO_NAME` export 到环境变量。

## 6. 重启 PicList + **确认默认图床是 GitHub**

```bash
# 再开一次，让新配置生效
open -a PicList
```

告诉用户**两件事必须做**：

1. 看菜单栏 PicList 图标是否活着；然后把窗口关了（不是 quit，只是关窗口），PicList 在后台跑，监听 36677 端口
2. **在关窗口前：点开 PicList → 左侧栏 `PicBed` → `GitHub`**，**确认右上角状态是"已设为默认图床"**（或图床配置名字旁有 ★ / 勾 / 类似标记）
   - 如果不是默认：手动点"设为默认图床"按钮（或右上的星标）
   - **这一步漏了的常见表现**：粘贴图片时要么上传失败，要么上传到了别的图床（比如 PicList 默认的 smms）
   - 即使 Python 脚本写了 `picBed.current = 'github'`，也建议**眼睛确认一遍** UI 显示一致——否则可能是 PicList 启动时用 GUI 缓存覆盖了 data.json

> ⚠️ **历史教训**（2026-04-24 第 1 位朋友）：这一步漏了，跑到"粘贴截图测试"时才发现没上传到 GitHub。补上确认这一眼就能早发现。

## 7. 装 Obsidian 插件 + 写 plugin data.json

```bash
PLUGIN_ID="obsidian-image-auto-upload-plugin"
REPO_GH="renmu123/obsidian-image-auto-upload-plugin"
DIR=".obsidian/plugins/$PLUGIN_ID"

mkdir -p "$DIR"
curl -fsSL "https://github.com/$REPO_GH/releases/latest/download/main.js" -o "$DIR/main.js"
curl -fsSL "https://github.com/$REPO_GH/releases/latest/download/manifest.json" -o "$DIR/manifest.json"

# 写插件配置：告诉它走 PicGo HTTP 协议，连 localhost:36677
cat > "$DIR/data.json" << 'EOF'
{
  "uploadByClipSwitch": true,
  "uploader": "PicGo",
  "uploadServer": "http://127.0.0.1:36677/upload",
  "deleteServer": "http://127.0.0.1:36677/delete",
  "imageSizeSuffix": "",
  "picgoCorePath": "",
  "workOnNetWork": false,
  "fixPath": false,
  "applyImage": true,
  "newWorkBlackDomains": "",
  "deleteSource": false,
  "imageDesc": "origin",
  "remoteServerMode": false,
  "uploadedImages": []
}
EOF

# 加到 community-plugins.json（追加，去重）
python3 << PYEOF
import json, os
cpl = '.obsidian/community-plugins.json'
existing = []
if os.path.exists(cpl):
    existing = json.load(open(cpl))
if '$PLUGIN_ID' not in existing:
    existing.append('$PLUGIN_ID')
json.dump(existing, open(cpl, 'w'), indent=2)
PYEOF

echo "✓ Obsidian 插件装好"
```

## 8. 告诉用户激活 Community Plugins

跟 L2 一样的指引：

1. Obsidian 设置 → Community plugins → "Turn on community plugins"（如果之前没开过）
2. Community plugins 列表里找到 "Image auto upload Plugin"，确保它是 Enabled
3. `Cmd+R` 重载 Obsidian

## 9. 验证

让用户**在 Obsidian 里打开任意 markdown 文件**，粘贴一张截图。成功标志：

- 粘贴瞬间 Obsidian 里出现的是 `![image.png](https://cdn.jsdelivr.net/gh/<用户>/<repo>@main/....png)` 这样的 URL
- 打开 https://github.com/<用户>/<repo>，看到刚上传的图片文件

**如果粘贴失败或图上传到了别的地方**：回第 6 步检查 PicList 的默认图床是不是 GitHub。

## 失败速查

| 症状 | 原因 | 处理 |
|---|---|---|
| 粘贴后本地保留 png，URL 没变 | 插件没启用 / PicList 没在跑 | 检查 Obsidian 插件开关 + 菜单栏 PicList 图标是否在 |
| 粘贴后上传成功但 URL 不是 jsdelivr / 出在别的图床（如 smms） | PicList 默认图床不是 GitHub | 打开 PicList → PicBed → GitHub → 设为默认图床（第 6 步的常见遗漏） |
| 粘贴后报 "upload failed" | PicList 配置问题 | 打开 PicList → Upload → 手动拖一张图看报错 |
| PicList 的 Upload API Service 没启动 | `settings.server.enable` 没生效 | 在 PicList GUI 里 Settings → Advanced → Server Settings → Upload API Service Settings，手动开 toggle |
| 图床 repo 是 private | jsdelivr 服务不到 | 去 GitHub repo settings 改 Public |
| 截图敏感图片后悔 | 已经 push 到 public repo 了 | `git rm` + force push 可以删；但 GitHub 和爬虫可能已缓存。**提前告诉用户不要贴敏感内容** |

## 擦手

```bash
unset PAT GITHUB_USER REPO_NAME
```
